import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/ui/widget/content_layout_web.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/ai/ui/widget/add_module_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/ai/ui/widget/delete_module_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiModulesPage extends StatefulWidget {
  const AiModulesPage({super.key});

  @override
  State<AiModulesPage> createState() => _AiModulesPageState();
}

class _AiModulesPageState extends State<AiModulesPage> {
  @override
  void initState() {
    super.initState();
    final companyId = context.getCurrentUser?.companyId;
    if (companyId != null) {
      context.read<AiCubit>().load(companyId: companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Modules',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (context.getCurrentUser!.companyAdmin == true)
                ElevatedButton.icon(
                  onPressed: () {
                    final companyId = context.getCurrentUser?.companyId;
                    if (companyId != null) {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<AiCubit>(),
                          child: AddAiModuleDialog(companyId: companyId),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Module'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<AiCubit, AiState>(
            builder: (context, state) {
              if (state is AiError) {
                return Center(
                    child: Text(state.message ?? 'Failed to load modules'));
              }

              if (state is AiLoaded || state is AiLoading) {
                final modules = state is AiLoaded ? state.modules : [];

                return Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        color: const Color(0xFFEFEFEF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Expanded(child: Center(child: Text('Name'))),
                            const Expanded(
                              flex: 3,
                              child: Center(child: Text('URL')),
                            ),
                            if (context.getCurrentUser?.companyAdmin == true)
                              const Expanded(
                                flex: 2,
                                child: Center(child: Text('Active')),
                              ),
                            const Expanded(
                                child: Center(child: Text('Actions'))),
                          ],
                        ),
                      ),
                      if (state is AiLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state is AiLoaded)
                        Expanded(
                          child: modules.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.group_off,
                                          size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'No AI modules available.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: modules.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final module = modules[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(module.name),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Center(
                                              child: Text(
                                                module.url,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (context.getCurrentUser
                                                  ?.companyAdmin ==
                                              true)
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Switch(
                                                  value: module.enabled == 1,
                                                  onChanged: (val) {
                                                    final newEnabled =
                                                        val ? 1 : 0;
                                                    final companyId = context
                                                        .getCurrentUser
                                                        ?.companyId;
                                                    if (companyId != null) {
                                                      context
                                                          .read<AiCubit>()
                                                          .updateModule(
                                                            moduleId: module.id,
                                                            companyId:
                                                                companyId,
                                                            name: module.name,
                                                            url: module.url,
                                                            enabled: newEnabled,
                                                            isGlobal:
                                                                module.isGlobal,
                                                          );
                                                    }
                                                  },
                                                  inactiveThumbColor:
                                                      Colors.black,
                                                  activeTrackColor:
                                                      Colors.green,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            child: Center(
                                              child: TextButton(
                                                child:
                                                    const Text('Remove module'),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                      value: context
                                                          .read<AiCubit>(),
                                                      child: DeleteAiModuleDialog(
                                                          companyId: context
                                                              .getCurrentUser!
                                                              .companyId!,
                                                          moduleId: module.id),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                );
              }

              return const SizedBox(); // fallback
            },
          ),
        ],
      ),
    );
  }
}
