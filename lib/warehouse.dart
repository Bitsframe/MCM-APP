import 'package:flutter/material.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medicineapp/productwarehouse.dart';

// Category model
class Category {
  final String id;
  final String name;
  final bool archieved;

  Category({
    required this.id,
    required this.name,
    required this.archieved,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['category_id'].toString(),
      name: map['category_name'] ?? '',
      archieved: map['archived'] ?? false,
    );
  }
}

class WarehousePage extends StatefulWidget {
     final String userId;
  const WarehousePage({super.key,
   required this.userId,
  
  
  });
  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
    int _selectedIndex = 5;

  List<Category> allCategories = [];
  List<Category> filteredCategories = [];
  bool showArchived = false;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    fetchCategories();
    super.initState();
  }

  Future<void> fetchCategories() async {
    final response = await Supabase.instance.client
        .from('categories')
        .select()
        .order('category_name', ascending: true);

    setState(() {
      allCategories = (response as List)
          .map((item) => Category.fromMap(item))
          .toList();
      applyFilters();
    });
  }

  void applyFilters() {
    setState(() {
      filteredCategories = allCategories.where((cat) {
        final matchesSearch = cat.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return showArchived
            ? cat.archieved && matchesSearch
            : !cat.archieved && matchesSearch;
      }).toList();
    });
  }

  void _showAddCategorySheet(BuildContext context) {
    final TextEditingController _categoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Create Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  label: Text('Add Category'),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final newCategory = _categoryController.text.trim();
                    if (newCategory.isNotEmpty) {
                      await Supabase.instance.client.from('categories').insert({
                        'category_name': newCategory,
                        'archived': false,
                      });
                      Navigator.pop(context);
                      fetchCategories(); // Refresh
                    }
                  },
                  child: Text("Create"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryRow(String id, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id)),
          Expanded(flex: 3, child: Text(name)),
          TextButton.icon(
            onPressed: () async {
              await Supabase.instance.client
                  .from('categories')
                  .update({'archived': !showArchived})
                  .eq('category_id', id);
              fetchCategories(); // Refresh after archive/unarchive
            },
            icon: Icon(
              showArchived ? Icons.unarchive : Icons.archive,
              color: Colors.white,
            ),
            label: Text(
              showArchived ? "Unarchive" : "Archive",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoriesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    searchQuery = value;
                    applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: "Search By Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddCategorySheet(context),
                icon: Icon(Icons.add),
                label: Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  showArchived = false;
                  applyFilters();
                },
                icon: Icon(Icons.shield),
                label: Text("Active"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !showArchived ? Colors.black : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showArchived = true;
                  applyFilters();
                },
                icon: Icon(Icons.delete_outline),
                label: Text("Archive"),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey.shade100,
          child: Row(
            children: const [
              Expanded(
                flex: 1,
                child: Text(
                  "Category ID",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text("Action", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchCategories,
            child: ListView(
              children: filteredCategories
                  .map((cat) => buildCategoryRow(cat.id, cat.name))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warehouse", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: Icon(Icons.folder, color: Colors.black),
              text: "Categories",
            ),
            Tab(
              icon: Icon(Icons.widgets_outlined, color: Colors.black),
              text: "Products",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildCategoriesTab(),
          ProductWarehouse(),
        ],
      ),
  bottomNavigationBar: NavigatorBar(
        userId: widget.userId,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),


    );
  }
}
