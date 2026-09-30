import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final marketProv = Provider.of<MarketProvider>(context);
    final watchlistProv = Provider.of<WatchlistProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markets', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stocks'),
              Tab(text: 'Watchlist'),
              Tab(text: 'News'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. All Stocks Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (val) => marketProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search stocks...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: marketProv.filteredStocks.length,
                    itemBuilder: (context, index) {
                      final stock = marketProv.filteredStocks[index];
                      final isWatchlist = watchlistProv.isInWatchlist(stock.symbol);
                      return ListTile(
                        onTap: () => context.push('/stock-detail', extra: stock.symbol),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E293B),
                          child: Text(stock.symbol.substring(0, 2), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(stock.name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${stock.currentPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${stock.change >= 0 ? '+' : ''}${stock.changePercent}%', style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red, fontSize: 12)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(isWatchlist ? Icons.star : Icons.star_border, color: isWatchlist ? Colors.amber : Colors.grey),
                              onPressed: () {
                                if (isWatchlist) {
                                  watchlistProv.removeFromWatchlist(stock.symbol);
                                } else {
                                  watchlistProv.addToWatchlist(stock.symbol);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // 2. Watchlist Tab
            ListView.builder(
              itemCount: watchlistProv.watchlist.length,
              itemBuilder: (context, index) {
                final stock = watchlistProv.watchlist[index];
                return ListTile(
                  onTap: () => context.push('/stock-detail', extra: stock.symbol),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E293B),
                    child: Text(stock.symbol.substring(0, 2), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(stock.name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Text('₹${stock.currentPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              },
            ),

            // 3. Live News & Sentiments Tab (Now Dynamic)
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: marketProv.newsList.length,
              itemBuilder: (context, index) {
                final news = marketProv.newsList[index];
                
                // Determine visuals based on sentiment
                Color color = Colors.blue;
                IconData icon = Icons.article;
                if (news['sentiment'] == 'Bullish') {
                  color = Colors.green;
                  icon = Icons.trending_up;
                } else if (news['sentiment'] == 'Bearish') {
                  color = Colors.red;
                  icon = Icons.trending_down;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${news['source']} • ${_getTimeAgo(news['timestamp'])}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: color.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    news['sentiment'],
                                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
