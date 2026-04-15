import 'package:flutter/material.dart';
import '../services/village_api.dart';
import '../theme/app_theme.dart';

class VillageScreen extends StatefulWidget {
  const VillageScreen({super.key});

  @override
  State<VillageScreen> createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _pendingVillages = [];
  List<Map<String, String>> _approvedVillages = [];
  bool _showPending = true;

  final VillageApi _villageApi = VillageApi();

  @override
  void initState() {
    super.initState();
    _fetchVillages();
  }

  Future<void> _fetchVillages() async {
    setState(() => _isLoading = true);
    try {
      final items = await _villageApi.fetchVillages();

      setState(() {
        _pendingVillages = items.map<Map<String, String>>((item) {
          return {
            'id': item['id']?.toString() ?? item['name']?.toString() ?? 'temp_id',
            'name': item['name']?.toString() ?? item['villageName']?.toString() ?? 'Unknown',
            'population': item['population']?.toString() ?? 'N/A',
            'distance': item['distanceFromPanchayat']?.toString() != null
                ? '${item['distanceFromPanchayat']} km' : 'N/A',
            'network': item['networkFacility']?.toString() ?? 'N/A',
          };
        }).toList();
        _approvedVillages.clear();
      });
    } catch (e) {
      debugPrint('Error loading villages from API: $e');
      if (_pendingVillages.isEmpty && _approvedVillages.isEmpty && mounted) {
         setState(() {
          _pendingVillages = [
            {'id': '1', 'name': 'Rampur (Mock)', 'population': '3200', 'distance': '5 km', 'network': '4G'},
            {'id': '2', 'name': 'Sitapur (Mock)', 'population': '1500', 'distance': '12 km', 'network': '2G'},
          ];
          _approvedVillages = [
             {'id': '3', 'name': 'Chandrapur (Mock)', 'population': '2100', 'distance': '8 km', 'network': '3G'},
          ];
         });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveVillage(Map<String, String> village) async {
    setState(() => _isLoading = true);

    try {
      await _villageApi.approveVillage(village['id'] ?? '');
    } catch (e) {
      debugPrint('Error approving village: $e');
    }

    if (mounted) {
      setState(() {
        _pendingVillages.removeWhere((v) => v['id'] == village['id']);
        _approvedVillages.insert(0, village);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${village['name']} has been approved!', style: const TextStyle(color: Colors.white)), 
          backgroundColor: Colors.green
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentList = _showPending ? _pendingVillages : _approvedVillages;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                const SizedBox(height: 16),
                // Custom Segmented Toggle Control
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showPending = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _showPending ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _showPending ? [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                              ] : [],
                            ),
                            alignment: Alignment.center,
                              child: Text(
                              'Pending (${_pendingVillages.length})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _showPending ? AppTheme.primaryColor : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showPending = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showPending ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_showPending ? [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                              ] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Approved (${_approvedVillages.length})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_showPending ? Colors.green : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchVillages,
                    color: AppTheme.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: currentList.isEmpty ? 1 : currentList.length,
                      itemBuilder: (context, index) {
                        if (currentList.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32.0),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Icon(
                                  _showPending ? Icons.check_circle_outline : Icons.inbox_outlined, 
                                  size: 64, 
                                  color: Colors.grey[400]
                                 ),
                                 const SizedBox(height: 16),
                                 Text(
                                   _showPending ? 'All villages have been approved.' : 'No approved villages yet.', 
                                   style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                 ),
                              ],
                            ),
                          );
                        }
                        
                        return _buildVillageApproveChip(currentList[index], isPending: _showPending);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVillageApproveChip(Map<String, String> village, {required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPending ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                isPending ? Icons.location_city : Icons.verified_user_rounded,
                color: isPending ? AppTheme.secondaryColor : Colors.green, 
                size: 22
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  village['name'] ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pop: ${village['population']} • Dist: ${village['distance']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (isPending)
            ElevatedButton(
              onPressed: () => _approveVillage(village),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.check_circle, color: Colors.green, size: 14),
                   SizedBox(width: 4),
                   Text('Approved', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                 ]
              ),
            ),
        ],
      ),
    );
  }
}
