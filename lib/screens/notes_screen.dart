import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Voice Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateNoteDialog(context),
            tooltip: 'Create Note',
          ),
        ],
      ),
      body: Consumer<VoiceAssistantProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Quick voice note section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quick Voice Note',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the microphone to create a note with your voice',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _startVoiceNote(context, provider),
                      icon: Icon(provider.isListening ? Icons.stop : Icons.mic),
                      label: Text(provider.isListening ? 'Stop Recording' : 'Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isListening 
                            ? Colors.red 
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notes list
              Expanded(
                child: _buildNotesList(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesList(BuildContext context) {
    // Sample notes for demonstration
    final sampleNotes = [
      {'title': 'Meeting Notes', 'content': 'Discuss project timeline and deliverables', 'time': '2 hours ago'},
      {'title': 'Grocery List', 'content': 'Milk, bread, eggs, fruits, vegetables', 'time': '1 day ago'},
      {'title': 'Ideas', 'content': 'New app features: dark mode, voice commands, AI integration', 'time': '3 days ago'},
    ];

    if (sampleNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first voice note using the microphone above',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sampleNotes.length,
      itemBuilder: (context, index) {
        final note = sampleNotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.note,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              note['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  note['content']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note['time']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleNoteAction(context, value.toString(), note),
            ),
            onTap: () => _viewNote(context, note),
          ),
        );
      },
    );
  }

  void _startVoiceNote(BuildContext context, VoiceAssistantProvider provider) {
    if (provider.isListening) {
      provider.stopListening();
    } else {
      provider.startListening();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speak your note. Tap stop when finished.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCreateNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Note'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose how you want to create your note:'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement text note creation
            },
            icon: const Icon(Icons.keyboard),
            label: const Text('Type Note'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement voice note creation
            },
            icon: const Icon(Icons.mic),
            label: const Text('Voice Note'),
          ),
        ],
      ),
    );
  }

  void _handleNoteAction(BuildContext context, String action, Map<String, String> note) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit "${note['title']}" - Coming Soon!')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share "${note['title']}" - Coming Soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, note);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, String> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${note['title']}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewNote(BuildContext context, Map<String, String> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note['title']!),
        content: SingleChildScrollView(
          child: Text(note['content']!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Text-to-speech - Coming Soon!')),
              );
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Read Aloud'),
          ),
        ],
      ),
    );
  }
}
