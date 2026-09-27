import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProv = Provider.of<MarketProvider>(context);
    final watchlistProv = Provider.of<WatchlistProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markets & Watchlist', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Stocks'),
              Tab(text: 'Watchlist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Stocks Tab
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
            // Watchlist Tab
            ListView.builder(
              itemCount: watchlistProv.watchlist.length,
              itemBuilder: (context, index) {
                final stock = watchlistProv.watchlist[index];
                return ListTile(
                  onTap: () => context.push('/stock-detail', extra: stock.symbol),
                  title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(stock.name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Text('₹${stock.currentPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
