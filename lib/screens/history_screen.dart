import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/conversion_history.dart';
import '../models/currency.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterCurrency = 'All';
  
  @override
  Widget build(BuildContext context) {
    final historyService = context.read<HistoryService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterCurrency = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Currencies'),
              ),
              ...CurrencyData.currencies.map((currency) =>
                PopupMenuItem(
                  value: currency.code,
                  child: Text('${currency.flag} ${currency.code}'),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => _exportHistory(historyService),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear History',
            onPressed: () => _confirmClearHistory(context, historyService),
          ),
        ],
      ),
      body: FutureBuilder<List<ConversionHistory>>(
        future: _getFilteredHistory(historyService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading history: ${snapshot.error}'),
            );
          }
          
          final history = snapshot.data ?? [];
          
          if (history.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              _buildStatistics(history),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final conversion = history[index];
                    return _buildHistoryCard(context, conversion, historyService);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<List<ConversionHistory>> _getFilteredHistory(HistoryService service) async {
    final history = await service.getHistory();
    
    if (_filterCurrency == 'All') {
      return history;
    }
    
    return history.where((h) =>
        h.fromCurrency == _filterCurrency || h.toCurrency == _filterCurrency).toList();
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversion history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatistics(List<ConversionHistory> history) {
    final onlineCount = history.where((h) => h.wasOnline).length;
    final offlineCount = history.length - onlineCount;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.numbers,
              label: 'Total',
              value: history.length.toString(),
            ),
            _buildStatItem(
              icon: Icons.cloud_done,
              label: 'Online',
              value: onlineCount.toString(),
              color: Colors.green,
            ),
            _buildStatItem(
              icon: Icons.cloud_off,
              label: 'Offline',
              value: offlineCount.toString(),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistoryCard(
    BuildContext context,
    ConversionHistory conversion,
    HistoryService service,
  ) {
    final fromCurrency = CurrencyData.findByCode(conversion.fromCurrency);
    final toCurrency = CurrencyData.findByCode(conversion.toCurrency);
    final dateFormat = DateFormat('MMM dd, HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fromCurrency?.flag ?? '💱',
              style: const TextStyle(fontSize: 24),
            ),
            const Icon(Icons.arrow_downward, size: 16),
            Text(
              toCurrency?.flag ?? '💱',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        title: Text(
          '${conversion.amount.toStringAsFixed(2)} ${conversion.fromCurrency} → '
          '${conversion.result.toStringAsFixed(2)} ${conversion.toCurrency}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Rate: 1 ${conversion.fromCurrency} = '
              '${conversion.exchangeRate.toStringAsFixed(4)} ${conversion.toCurrency}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  conversion.wasOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 12,
                  color: conversion.wasOnline ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(conversion.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => _confirmDeleteConversion(context, service, conversion.id),
        ),
      ),
    );
  }
  
  void _confirmClearHistory(BuildContext context, HistoryService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all conversion history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await service.clearHistory();
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteConversion(
    BuildContext context,
    HistoryService service,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversion'),
        content: const Text('Are you sure you want to delete this conversion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await service.deleteConversion(id);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _exportHistory(HistoryService service) {
    final csv = service.exportToCSV();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: SingleChildScrollView(
          child: SelectableText(csv),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
