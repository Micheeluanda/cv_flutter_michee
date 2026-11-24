import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_exception.dart';
import '../../models/famille_membre.dart';
import 'family_repository.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key, this.repository});

  final FamilyRepository? repository;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late final FamilyRepository _repository =
      widget.repository ?? FamilyRepository();
  List<FamilleMembre> _members = const [];
  bool _loading = true;
  String? _loadError;
  int? _loadingMemberId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final members = await _repository.fetchMembers();
      if (!mounted) return;
      setState(() => _members = members);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm({FamilleMembre? member}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _MemberFormDialog(repository: _repository, member: member),
    );
    if (!mounted || saved != true) return;

    _showMessage(member == null ? 'Membre ajouté.' : 'Membre modifié.');
    await _loadMembers();
  }

  Future<void> _editMember(FamilleMembre member) async {
    setState(() => _loadingMemberId = member.id);
    try {
      final currentMember = await _repository.fetchMember(member.id);
      if (!mounted) return;
      await _openForm(member: currentMember);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _loadingMemberId = null);
    }
  }

  Future<void> _deleteMember(FamilleMembre member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          'Cette action supprimera ${member.nomComplet} de la liste familiale.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loadingMemberId = member.id);
    try {
      await _repository.deleteMember(member.id);
      if (!mounted) return;
      _showMessage('Membre supprimé.');
      await _loadMembers();
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _loadingMemberId = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ma famille',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les personnes qui donnent du sens à mon parcours.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualiser',
                      onPressed: _loading ? null : _loadMembers,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(child: _buildContent()),
              ],
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Ajouter un membre'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: _StatusMessage(
          icon: Icons.cloud_off_rounded,
          title: 'Impossible de charger les membres',
          message: _loadError!,
          actionLabel: 'Réessayer',
          onAction: _loadMembers,
        ),
      );
    }
    if (_members.isEmpty) {
      return const Center(
        child: _StatusMessage(
          icon: Icons.family_restroom_rounded,
          title: 'Aucun membre enregistré',
          message: 'Ajoutez un membre pour commencer votre liste familiale.',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 82),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 320,
          ),
          itemCount: _members.length,
          itemBuilder: (context, index) {
            final member = _members[index];
            return _MemberCard(
              member: member,
              imageUrl:
                  member.imageUrl == null || member.imageUrl!.trim().isEmpty
                  ? null
                  : _repository
                        .resolveImageUrl(member.imageUrl!.trim())
                        .toString(),
              busy: _loadingMemberId == member.id,
              onEdit: () => _editMember(member),
              onDelete: () => _deleteMember(member),
            );
          },
        );
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.imageUrl,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilleMembre member;
  final String? imageUrl;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photoUrl = imageUrl;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? _InitialsAvatar(member: member)
                        : Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _InitialsAvatar(member: member),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.nomComplet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            member.parente,
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier',
                      onPressed: busy ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: busy ? null : onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: scheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                    if (busy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MemberDetail(label: 'Nom', value: member.nom),
            _MemberDetail(label: 'Postnom', value: member.postnom),
            _MemberDetail(label: 'Prénom', value: member.prenom),
            _MemberDetail(
              label: 'Date de naissance',
              value: _formatDate(member.dateNaissance),
            ),
            _MemberDetail(
              label: 'Lieu de naissance',
              value: member.lieuNaissance,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _MemberDetail extends StatelessWidget {
  const _MemberDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              '$label :',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.member});

  final FamilleMembre member;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: member.initiales.isEmpty
            ? Icon(
                Icons.family_restroom_rounded,
                color: scheme.primary,
                size: 28,
              )
            : Text(
                member.initiales,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberFormDialog extends StatefulWidget {
  const _MemberFormDialog({required this.repository, this.member});

  final FamilyRepository repository;
  final FamilleMembre? member;

  @override
  State<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _postnomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _lieuController;
  late final TextEditingController _dateController;
  late final TextEditingController _parenteController;
  Uint8List? _photoBytes;
  String? _photoName;
  String? _errorMessage;
  bool _saving = false;

  bool get _editing => widget.member != null;
  bool get _hasExistingPhoto =>
      widget.member?.imageUrl?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nomController = TextEditingController(text: member?.nom ?? '');
    _postnomController = TextEditingController(text: member?.postnom ?? '');
    _prenomController = TextEditingController(text: member?.prenom ?? '');
    _lieuController = TextEditingController(text: member?.lieuNaissance ?? '');
    _dateController = TextEditingController(
      text: _formatDateForForm(member?.dateNaissance ?? ''),
    );
    _parenteController = TextEditingController(text: member?.parente ?? '');
  }

  String _formatDateForForm(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    _parenteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoName = image.name;
        _errorMessage = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'Impossible de sélectionner la photo : '
            '${error.message ?? error.code}',
      );
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final existing = DateTime.tryParse(_dateController.text);
    final earliestDate = DateTime(1800);
    final initialDate = existing == null || existing.isAfter(today)
        ? today
        : existing.isBefore(earliestDate)
        ? earliestDate
        : existing;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliestDate,
      lastDate: today,
      helpText: 'Date de naissance',
    );
    if (date == null) return;
    setState(() {
      _dateController.text =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    final fields = <String, String>{
      'nom': _nomController.text.trim(),
      'postnom': _postnomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'lieu_naissance': _lieuController.text.trim(),
      'date_naissance': _dateController.text.trim(),
      'parente': _parenteController.text.trim(),
    };

    try {
      if (_editing) {
        await widget.repository.updateMember(
          widget.member!.id,
          fields,
          photoBytes: _photoBytes,
          photoName: _photoName,
        );
      } else {
        await widget.repository.createMember(
          fields,
          photoBytes: _photoBytes,
          photoName: _photoName,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      final details = error.errors.entries
          .map((entry) => '${entry.key} : ${entry.value}')
          .join('\n');
      setState(() {
        _saving = false;
        _errorMessage = details.isEmpty
            ? error.message
            : '${error.message}\n$details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(_editing ? 'Modifier le membre' : 'Ajouter un membre'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField(_nomController, 'Nom'),
                _textField(_postnomController, 'Postnom'),
                _textField(_prenomController, 'Prénom'),
                _textField(_lieuController, 'Lieu de naissance'),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    suffixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  validator: _requiredValidator,
                ),
                _textField(_parenteController, 'Lien de parenté'),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickPhoto,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    _photoName ??
                        (_editing && _hasExistingPhoto
                            ? 'Changer la photo'
                            : 'Ajouter une photo (facultatif)'),
                  ),
                ),
                if (_photoBytes != null || _hasExistingPhoto) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: _photoBytes != null
                            ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                            : Image.network(
                                widget.repository
                                    .resolveImageUrl(
                                      widget.member!.imageUrl!.trim(),
                                    )
                                    .toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    ColoredBox(
                                      color: scheme.surfaceContainerHighest,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    ),
                              ),
                      ),
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_editing ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: label),
        validator: _requiredValidator,
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty
      ? 'Ce champ est obligatoire.'
      : null;
}
