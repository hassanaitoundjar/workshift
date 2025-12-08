import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../providers/database_provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class AddClientScreen extends StatefulWidget {
  final Client? client;

  const AddClientScreen({super.key, this.client});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _locationController.text = widget.client!.location ?? '';
      _phoneController.text = widget.client!.contactPhone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    final client = Client(
      id: widget.client?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      contactPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      createdAt: widget.client?.createdAt ?? DateTime.now(),
    );

    if (widget.client == null) {
      await dbProvider.addClient(client);
    } else {
      await dbProvider.updateClient(client);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: isSmallScreen ? 200 : 240,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.maxHeight < 120;
                  if (isCollapsed) {
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          widget.client == null ? l10n.addClient : l10n.editClient,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              titlePadding: EdgeInsets.zero,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.accentGradient,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = constraints.maxHeight;
                      final isExpanded = availableHeight > 180;
                      final isVeryCompact = availableHeight < 120;
                      
                      // Calculate sizes based on available space
                      final iconPadding = isVeryCompact ? 8.0 : (isExpanded ? 16.0 : 12.0);
                      final iconSize = isVeryCompact
                          ? 24.0
                          : (isExpanded
                              ? (isSmallScreen ? 32.0 : 40.0)
                              : (isSmallScreen ? 24.0 : 28.0));
                      final titleSize = isVeryCompact
                          ? 18.0
                          : (isExpanded
                              ? (isSmallScreen ? 28.0 : 32.0)
                              : (isSmallScreen ? 20.0 : 24.0));
                      final spacing = isVeryCompact ? 4.0 : (isExpanded ? 16.0 : 8.0);
                      final subtitleSize = isExpanded
                          ? (isSmallScreen ? 14.0 : 16.0)
                          : (isSmallScreen ? 12.0 : 13.0);
                      
                      // Calculate top padding to ensure content fits
                      final topPadding = isVeryCompact
                          ? 8.0
                          : (isExpanded ? 50.0 : 20.0);
                      final bottomPadding = isVeryCompact ? 4.0 : (isExpanded ? 12.0 : 4.0);

                      return Padding(
                        padding: EdgeInsets.only(
                          top: topPadding,
                          left: 16,
                          right: 16,
                          bottom: bottomPadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.business_rounded,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ),
                            if (spacing > 0) SizedBox(height: spacing),
                            Flexible(
                              child: Text(
                                widget.client == null ? 'Add Client' : 'Edit Client',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isExpanded && availableHeight > 200) ...[
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  widget.client == null
                                      ? l10n.createNewClient
                                      : l10n.updateClientInformation,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: subtitleSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            actions: [
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _saveClient,
                      tooltip: 'Save',
                    ),
                  ),
                ),
            ],
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Client Name Card
                    _buildFieldCard(
                      context,
                      title: l10n.clientName,
                      icon: Icons.business_rounded,
                      iconColor: AppTheme.accentColor,
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.enterClientName,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterClientName;
                          }
                          return null;
                        },
                      ),
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Location Card
                    _buildFieldCard(
                      context,
                      title: l10n.location,
                      icon: Icons.location_on_rounded,
                      iconColor: AppTheme.primaryColor,
                      child: TextFormField(
                        controller: _locationController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.enterLocation,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterLocation;
                          }
                          return null;
                        },
                      ),
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Phone Number Card (Optional)
                    _buildFieldCard(
                      context,
                      title: l10n.phoneNumber,
                      subtitle: '(${l10n.optional})',
                      icon: Icons.phone_rounded,
                      iconColor: AppTheme.secondaryColor,
                      child: TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.enterPhoneNumber,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 32 : 40),

                    // Save Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveClient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 18 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading) ...[
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else ...[
                              const Icon(Icons.check_circle_rounded, size: 24),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              widget.client == null
                                  ? l10n.addClient
                                  : l10n.updateClient,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 17 : 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isSmallScreen ? 20 : 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 15 : 16,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
