import 'package:flutter/material.dart';
import 'package:mainproject_2/article_detail.dart';
import 'package:mainproject_2/newsmodelApi.dart';

import 'model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NewsApiModel>> futureNews;
  String selectedCategory = 'business'; // Default category
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureNews = getNews(category: selectedCategory);
  }

  void _updateCategory(String category) {
    setState(() {
      selectedCategory = category;
      futureNews = getNews(
          category: selectedCategory); // Fetch news for the selected category
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Headlines'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('Business', Icons.business, 'business'),
                _buildCategoryButton(
                    'Entertainment', Icons.movie, 'entertainment'),
                _buildCategoryButton('Sports', Icons.sports, 'sports'),
              ],
            ),
          ),
          // TextField for search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearchQuery, // Update search query dynamically
              decoration: InputDecoration(
                labelText: 'Search News',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate:
                          NewsSearchDelegate(futureNews, query: _searchQuery),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NewsApiModel>>(
              future: futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No articles found.'));
                } else {
                  List<NewsApiModel> articles = snapshot.data!;

                  // Filter the articles based on search query
                  if (_searchQuery.isNotEmpty) {
                    articles = articles.where((article) {
                      return article.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          article.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: articles.map((article) {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Larger Image
                                article.urlToImage.isNotEmpty
                                    ? Image.network(
                                        article.urlToImage,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported,
                                        size: 100),
                                const SizedBox(height: 8),
                                // Title
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Description
                                Text(
                                  article.description,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Read More Button
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailPage(
                                                  article: article),
                                        ),
                                      );
                                    },
                                    child: const Text('Read More'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon, String category) {
    return GestureDetector(
      onTap: () => _updateCategory(category),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: selectedCategory == category ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selectedCategory == category ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final Future<List<NewsApiModel>> futureNews;
  final String query;

  NewsSearchDelegate(this.futureNews, {required this.query});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<NewsApiModel>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          } else {
            List<NewsApiModel> articles = snapshot.data!;

            // Display the articles for the selected category
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: article.urlToImage.isNotEmpty
                        ? Image.network(
                            article.urlToImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search articles by title or description.'),
    );
  }
}
