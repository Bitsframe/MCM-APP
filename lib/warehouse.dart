import 'package:easy_localization/easy_localization.dart';
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
          top: 30,
          left: 20,
          right: 20,
        ),
        child: Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add Category".tr(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ), IconButton(
  onPressed: () {
    Navigator.pop(context);
  },
  padding: EdgeInsets.zero, // removes extra padding
  constraints: const BoxConstraints(), // keeps size compact
  icon: Container(
    width: 24,
    height: 24,
    decoration: const BoxDecoration(
      color: Color(0xFFE8EAF6), // light grey circle background
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.close,
      size: 16,
      color: Colors.black54, // X color
    ),
  ),
)

               
              ],
            ),
            const Divider(),
            const SizedBox(height: 25),
            Text("Category".tr(), style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18)),
            const SizedBox(height: 25),
      
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: const Color.fromARGB(255, 183, 182, 182)
                )
              ),
              child: TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Apply circular border radius
            borderSide: BorderSide.none, // Or specify a border side if needed
          ),
          filled: true, // Often used with OutlineInputBorder for background color
          fillColor: Colors.grey[200], // Example fill color
                  label: Text('Add Category'.tr()),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel".tr(),style: TextStyle(color:const Color(0xFF0057FF),),),
                ),
                SizedBox(width: 12),
                OutlinedButton(
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
                  child: Text("Create".tr(),style:TextStyle(color:const Color(0xFF0057FF),)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color.fromARGB(255, 183, 182, 182)
                    ),

                    
                backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 244, 241, 241),
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
          Expanded(flex: 2, child: Text(id)),
          Expanded(flex:3 , child: Text(name)),
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
              color:showArchived ? Colors.green : Colors.red ,
            ),
            label: Text(
              showArchived ? "Unarchive".tr() : "Archive".tr(),
              style: TextStyle(color: showArchived ? Colors.green : Colors.red,),
            ),
            style: TextButton.styleFrom(
              backgroundColor: showArchived ? Color(0xFFDCFCE7) : Color.fromARGB(255, 252, 207, 208),
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
                    
                    hintText: "Search by Category".tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
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
                label: Text("Active".tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !showArchived ?  const Color(0xFF0057FF): const Color(0xFFF1F4F9),
                  foregroundColor: !showArchived ?  Colors.white:Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showArchived = true;
                  applyFilters();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: showArchived ?  const Color(0xFF0057FF):const Color(0xFFF1F4F9) ,
                  foregroundColor: showArchived ? Colors.white :Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                ),
                icon: Icon(Icons.folder_zip_sharp),
                label: Text("Archived".tr()),
                // style: OutlinedButton.styleFrom(
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                // ),
              ),
               SizedBox(width: 2),
             
           Expanded( // Wrap the button with Expanded
  child: ElevatedButton.icon(
    onPressed: () => _showAddCategorySheet(context),
    icon: Icon(Icons.add),
    label: Text(
      "Add Category".tr(),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
    ),
    style: ElevatedButton.styleFrom(
      side: BorderSide(
        width: 1,
        color: const Color(0xFF0057FF),
      ),
      backgroundColor: const Color(0xFFE4E8F3),
      foregroundColor: const Color(0xFF0057FF),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    ),
  ),
),
           
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFE4E8F3),
          child: Row(
            children:  [
              Expanded(
                flex: 2,
                child: Text(
                  "Category ID".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Name".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text("Action".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
     backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black,
                          
                        ),

                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      //  Text('Back', style: TextStyle(color: Colors.black,fontSize: 10)),
                     

          ],
        ),
        centerTitle: true,
          title: Text("Warehouse".tr(), style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0057FF), // Blue when selected
  unselectedLabelColor: Colors.grey, // Grey when unselected
  indicatorColor: Color(0xFF0057FF), // Optional underline indicator color
          
          tabs: [
            Tab(
              icon: Icon(Icons.folder, ),
              text: "Categories".tr(),
            ),
            Tab(
              icon: Icon(Icons.shopping_cart_checkout_sharp,),
              text: "Products".tr(),
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
