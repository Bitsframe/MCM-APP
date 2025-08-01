import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductWarehouse extends StatefulWidget {
  const ProductWarehouse({super.key});

  @override
  State<ProductWarehouse> createState() => _ProductWarehouseState();
}

class _ProductWarehouseState extends State<ProductWarehouse> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> allActiveProducts = [];
  List<Map<String, dynamic>> allAssignProducts = [];
  List<Map<String, dynamic>> filteredActiveProducts = [];
  List<Map<String, dynamic>> filteredAssignProducts = [];

  bool isLoading = true;
  bool showActive = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.trim().toLowerCase();
      _filterProducts();
    });
  }

  Future<void> fetchProducts() async {
    final response = await supabase
        .from('products')
        .select(
          'product_id, product_name, price, stock, archived, categories(category_name)',
        );

    final data = response as List;

    final List<Map<String, dynamic>> allFetched = data
        .map<Map<String, dynamic>>((p) {
          return {
            'product_id': p['product_id'],
            'product_name': p['product_name'],
            'price': p['price'],
            'stock': p['stock'],
            'archived': p['archived'],
            'category_name': p['categories']?['category_name'] ?? 'Unknown',
          };
        })
        .toList();

    setState(() {
      allActiveProducts = allFetched
          .where((p) => p['archived'] == false)
          .toList();
      allAssignProducts = allFetched
          .where((p) => p['archived'] == true)
          .toList();
      _filterProducts();
      isLoading = false;
    });
  }

  void _filterProducts() {
    filteredActiveProducts = allActiveProducts
        .where((p) => p['product_name'].toLowerCase().contains(searchQuery))
        .toList();

    filteredAssignProducts = allAssignProducts
        .where((p) => p['product_name'].toLowerCase().contains(searchQuery))
        .toList();
  }

  Widget buildProductCards(List<Map<String, dynamic>> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final bool isArchived = p['archived'] ?? false;
        final productId = p['product_id'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${p['product_name']} - ${p['category_name']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Price: \$${p['price']}",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Stock: ${p['stock']}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _updateProductSheet(
                          context,
                          p,
                        ); // updated to pass product
                      },
                      icon: const Icon(Icons.update_outlined),
                      label: const Text(
                        "Update",
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (productId == null) return;

                        final updatedArchived = !isArchived;

                        await Supabase.instance.client
                            .from('products')
                            .update({'archived': updatedArchived})
                            .eq('product_id', productId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedArchived
                                    ? "Product archived"
                                    : "Product reactivated",
                              ),
                            ),
                          );
                          await fetchProducts();
                        }
                      },
                      icon: Icon(isArchived ? Icons.unarchive : Icons.archive),
                      label: Text(
                        isArchived ? "Unarchive" : "Archive",
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isArchived
                            ? Color(0xFFDCFCE7)
                            : Color.fromARGB(255, 253, 178, 180),
                        foregroundColor: isArchived ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAssignProductSheet(context, productId);
                        // TODO: Assign logic
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Assign",
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDCFCE7),
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateProductSheet(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    final supabase = Supabase.instance.client;

    final List<dynamic> categoriesData = await supabase
        .from('categories')
        .select('category_id, category_name')
        .eq('archived', false)
        .order('category_name');

    if (categoriesData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No categories found.")));
      return;
    }

    final TextEditingController _nameController = TextEditingController(
      text: product['product_name'],
    );
    final TextEditingController _priceController = TextEditingController(
      text: product['price'].toString(),
    );
    final TextEditingController _stockController = TextEditingController(
      text: product['stock'].toString(),
    );
    Map<String, dynamic>? selectedCategory = categoriesData.first; // ✅ correct

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +30,
          left: 30,   // increased from 20
    right: 30,  // increased from 20
    top: 40,    // increased from 24
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Wrap(
            
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Update Product",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

  
              // Category dropdown
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedCategory,
                items: categoriesData
                    .map<DropdownMenuItem<Map<String, dynamic>>>((category) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: category,
                        child: Text(category['category_name']),
                      );
                    })
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: InputDecoration(
                  hintText: "Select Category",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Product Name",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                     borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Price",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                   borderSide: BorderSide(
                                color: Colors.grey.shade300, // lighter grey border
                              ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Stock",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                             color: Colors.grey.shade300, // lighter grey border
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
],
),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",style: TextStyle(color: const Color(0xFF0057FF),),),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text.trim();
                      final double? price = double.tryParse(
                        _priceController.text.trim(),
                      );
                      final int? stock = int.tryParse(
                        _stockController.text.trim(),
                      );
                      final int categoryId = selectedCategory?['category_id'];

                      if (name.isEmpty ||
                          price == null ||
                          stock == null ||
                          categoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please fill all fields properly."),
                          ),
                        );
                        return;
                      }

                      await supabase
                          .from('products')
                          .update({
                            'product_name': name,
                            'price': price,
                            'stock': stock,
                            'category_id': categoryId,
                          })
                          .eq('product_id', product['product_id']);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Product updated successfully."),
                          ),
                        );
                        await fetchProducts();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                     
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Update",style: TextStyle(color:const Color(0xFF0057FF),),),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductSheet(BuildContext context) async {
    final SupabaseClient supabase = Supabase.instance.client;

    final List<dynamic> categoriesData = await supabase
        .from('categories')
        .select('category_id, category_name')
        .eq('archived', false)
        .order('category_name');

    if (categoriesData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No categories found.")));
      return;
    }

    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _priceController = TextEditingController();
    final TextEditingController _unitsController = TextEditingController();
    bool transferTo = false;

    Map<String, dynamic>? selectedCategory = categoriesData.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +30,
          left: 30,
          right: 30,
          top: 30,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Wrap(
            children: [
              
                                               Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Create Product",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 25),
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [


              // Category Dropdown
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedCategory,
                items: categoriesData
                    .map<DropdownMenuItem<Map<String, dynamic>>>((category) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: category,
                        child: Text(category['category_name']),
                      );
                    })
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: InputDecoration(
                  hintText: "Select Category",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                     borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Product Name",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price and Units
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Price",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                           borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Units",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                           borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
                              ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: transferTo,
                    onChanged: (value) =>
                        setState(() => transferTo = value ?? false),
                  ),
                  const Text("to"),
                ],
              ),

              
],),
const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",style: TextStyle(color:const Color(0xFF0057FF),),),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text.trim();
                      final double? price = double.tryParse(
                        _priceController.text,
                      );
                      final int? units = int.tryParse(_unitsController.text);
                      final int categoryId = selectedCategory?['category_id'];

                      if (name.isEmpty ||
                          price == null ||
                          units == null ||
                          categoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Fill all fields properly.")),
                        );
                        return;
                      }

                      try {
                        await supabase.from('products').insert({
                          'product_name': name,
                          'price': price,
                          'stock': units,
                          'archived': false,
                          'category_id': categoryId,
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Product added successfully."),
                          ),
                        );

                        // Optional: refresh product list
                        if (context.mounted) {
                          final state = context
                              .findAncestorStateOfType<
                                _ProductWarehouseState
                              >();
                          state?.fetchProducts();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                   
                    child: const Text("Create",style: TextStyle(color:const Color(0xFF0057FF),),),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignProductSheet(BuildContext context, int productId) async {
    final supabase = Supabase.instance.client;

    final allLocations =
        await supabase.from('Locations').select('id, title') as List<dynamic>;

    List<Map<String, dynamic>> locations = allLocations
        .map((e) => e as Map<String, dynamic>)
        .toList();

    List<Map<String, dynamic>> filteredLocations = [...locations];
    bool selectAll = false;
    List<int> selectedLocationIds = [];

    final TextEditingController searchController = TextEditingController();
    final TextEditingController unitsController = TextEditingController();

    final product = await supabase
        .from('products')
        .select('stock')
        .eq('product_id', productId)
        .maybeSingle();

    final int availableStock = product?['stock'] ?? 0;
    final String stockType = 'Limited';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            searchController.addListener(() {
              setState(() {
                final query = searchController.text.toLowerCase();
                filteredLocations = locations.where((location) {
                  final title = location['title'].toString().toLowerCase();
                  return title.contains(query);
                }).toList();
              });
            });

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assign Product",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 25),
                  // Search, List, etc.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search by title",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text("Select All"),
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value!;
                        if (selectAll) {
                          selectedLocationIds = filteredLocations
                              .map<int>((l) => l['id'] as int)
                              .toList();
                        } else {
                          selectedLocationIds.clear();
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
                        final isSelected = selectedLocationIds.contains(
                          location['id'],
                        );

                        return CheckboxListTile(
                          title: Text(
                            location['title'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                selectedLocationIds.add(location['id']);
                              } else {
                                selectedLocationIds.remove(location['id']);
                                selectAll = false;
                              }
                            });
                          },
                           activeColor: const Color(0xFF0057FF), // Selection color
  controlAffinity: ListTileControlAffinity.trailing, // Checkbox on right side
                        
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Units",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: unitsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "0",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 205, 204, 204)

                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 📦 Stock Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Stock type:"),
                                  Text("Limited"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Available stock:"),
                                  Text("$availableStock"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🔘 Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),

                              child: const Text("Cancel",style: TextStyle(color: const Color(0xFF0057FF),),),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () async {
                                final int? units = int.tryParse(
                                  unitsController.text,
                                );
                                if (selectedLocationIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Select at least one location",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (units == null || units <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Enter a valid unit amount",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final totalRequiredStock =
                                    units * selectedLocationIds.length;

                                if (availableStock < totalRequiredStock) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Not enough stock. You need $totalRequiredStock units.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                for (final locationId in selectedLocationIds) {
                                  final existing = await supabase
                                      .from('inventory')
                                      .select('inventory_id, quantity')
                                      .eq('product_id', productId)
                                      .eq('location_id', locationId)
                                      .maybeSingle();

                                  if (existing != null) {
                                    final int currentQty =
                                        existing['quantity'] ?? 0;
                                    await supabase
                                        .from('inventory')
                                        .update({
                                          'quantity': currentQty + units,
                                        })
                                        .eq(
                                          'inventory_id',
                                          existing['inventory_id'],
                                        );
                                  } else {
                                    await supabase.from('inventory').insert({
                                      'product_id': productId,
                                      'location_id': locationId,
                                      'quantity': units,
                                    });
                                  }
                                }

                                await supabase
                                    .from('products')
                                    .update({
                                      'stock':
                                          availableStock - totalRequiredStock,
                                    })
                                    .eq('product_id', productId);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Product assigned successfully",
                                    ),
                                  ),
                                );
                              },
                             
                              child: const Text("Assign",style: TextStyle(color:const Color(0xFF0057FF), ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ...continue your Assign button etc.
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  //   void _showAssignProductSheet(BuildContext context, int productId) async {
  //     List<Map<String, dynamic>> filteredLocations = [];

  //     final supabase = Supabase.instance.client;

  //     final locations = await supabase.from('Locations').select('id, title');

  //     bool selectAll = false;
  //     List<int> selectedLocationIds = [];

  //     final categoryController = TextEditingController();
  //     final unitsController = TextEditingController();

  //     final product = await supabase
  //         .from('products')
  //         .select('stock')
  //         .eq('product_id', productId)
  //         .maybeSingle();

  //     final int availableStock = product?['stock'] ?? 0;
  //     final String stockType = 'Limited';

  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //       ),
  //       builder: (context) => Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //           left: 20,
  //           right: 20,
  //           top: 24,
  //         ),
  //         child: StatefulBuilder(
  //           builder: (context, setState) => SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                    Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Assign",
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ],
  //             ),
  //             const Divider(),
  //                 const SizedBox(height: 16),
  // Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //   child: TextField(
  //     controller: searchController,
  //     decoration: InputDecoration(
  //       hintText: "Search by title",
  //       prefixIcon: Icon(Icons.search),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey.shade100,
  //     ),
  //     onChanged: (value) {
  //       setState(() {
  //         // Filtering handled in ListView below
  //       });
  //     },
  //   ),
  // ),

  // const SizedBox(height: 16),

  // // ✅ Select All Checkbox
  // CheckboxListTile(
  //   title: const Text("Select All"),
  //   value: selectAll,
  //   onChanged: (value) {
  //     setState(() {
  //       selectAll = value!;
  //       if (selectAll) {
  //         selectedLocationIds = filteredLocations
  //             .map<int>((l) => l['id'] as int)
  //             .toList();
  //       } else {
  //         selectedLocationIds.clear();
  //       }
  //     });
  //   },
  //   controlAffinity: ListTileControlAffinity.leading,
  // ),

  // // 📍 Location List
  // Container(
  //   height: 400,
  //   decoration: BoxDecoration(
  //     border: Border.all(color: Colors.grey.shade300),
  //     borderRadius: BorderRadius.circular(8),
  //   ),
  //   child: ListView.builder(
  //     itemCount: filteredLocations.length,
  //     itemBuilder: (context, index) {
  //       final location = filteredLocations[index];
  //       final isSelected = selectedLocationIds.contains(location['id']);

  //       return CheckboxListTile(
  //         title: Text(
  //           location['title'],
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         value: isSelected,
  //         onChanged: (value) {
  //           setState(() {
  //             if (value!) {
  //               selectedLocationIds.add(location['id']);
  //             } else {
  //               selectedLocationIds.remove(location['id']);
  //               selectAll = false;
  //             }
  //           });
  //         },
  //         controlAffinity: ListTileControlAffinity.leading,
  //       );
  //     },
  //   ),
  // ),
  //                 // Select All Checkbox
  //                 // CheckboxListTile(
  //                 //   title: const Text("Select All"),
  //                 //   value: selectAll,
  //                 //   onChanged: (value) {
  //                 //     setState(() {
  //                 //       selectAll = value!;
  //                 //       if (selectAll) {
  //                 //         selectedLocationIds = locations
  //                 //             .map<int>((l) => l['id'] as int)
  //                 //             .toList();
  //                 //       } else {
  //                 //         selectedLocationIds.clear();
  //                 //       }
  //                 //     });
  //                 //   },
  //                 //   controlAffinity: ListTileControlAffinity.leading,
  //                 // ),

  //                 // // Location List
  //                 // Container(
  //                 //   height: 400,
  //                 //   decoration: BoxDecoration(
  //                 //     border: Border.all(color: Colors.grey.shade300),
  //                 //     borderRadius: BorderRadius.circular(8),
  //                 //   ),
  //                 //   child: ListView.builder(
  //                 //     itemCount: locations.length,
  //                 //     itemBuilder: (context, index) {
  //                 //       final location = locations[index];
  //                 //       final isSelected = selectedLocationIds.contains(
  //                 //         location['id'],
  //                 //       );

  //                 //       return CheckboxListTile(
  //                 //         title: Text(
  //                 //           location['title'],
  //                 //           overflow: TextOverflow.ellipsis,
  //                 //         ),
  //                 //         value: isSelected,
  //                 //         onChanged: (value) {
  //                 //           setState(() {
  //                 //             if (value!) {
  //                 //               selectedLocationIds.add(location['id']);
  //                 //             } else {
  //                 //               selectedLocationIds.remove(location['id']);
  //                 //               selectAll = false;
  //                 //             }
  //                 //           });
  //                 //         },
  //                 //         controlAffinity: ListTileControlAffinity.leading,
  //                 //       );
  //                 //     },
  //                 //   ),
  //                 // ),

  //                 const SizedBox(height: 12),
  //                 Text("${selectedLocationIds.length} Selected"),

  //                 const SizedBox(height: 16),
  //                 const Align(
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     "Units",
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 TextField(
  //                   controller: unitsController,
  //                   keyboardType: TextInputType.number,
  //                   decoration: InputDecoration(
  //                     hintText: "0",
  //                     filled: true,
  //                     fillColor: Colors.grey.shade100,
  //                     border: OutlineInputBorder(
  //                       borderSide: BorderSide.none,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Stock Info
  //                 Container(
  //                   width: double.infinity,
  //                   padding: const EdgeInsets.all(12),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade50,
  //                     borderRadius: BorderRadius.circular(8),
  //                     border: Border.all(color: Colors.grey.shade200),
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [const Text("Stock type:"), Text(stockType)],
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           const Text("Available stock:"),
  //                           Text("$availableStock"),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 24),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     OutlinedButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text("Cancel"),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     ElevatedButton(
  //                       onPressed: () async {
  //                         final int? units = int.tryParse(unitsController.text);
  //                         if (selectedLocationIds.isEmpty) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text("Select at least one location"),
  //                             ),
  //                           );
  //                           return;
  //                         }

  //                         if (units == null || units <= 0) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text("Enter a valid unit amount"),
  //                             ),
  //                           );
  //                           return;
  //                         }

  //                         final totalRequiredStock =
  //                             units * selectedLocationIds.length;

  //                         if (availableStock < totalRequiredStock) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             SnackBar(
  //                               content: Text(
  //                                 "Not enough stock. You need $totalRequiredStock units.",
  //                               ),
  //                             ),
  //                           );
  //                           return;
  //                         }
  //                         print(selectedLocationIds);

  //                         // Assign to each location
  //                         for (final locationId in selectedLocationIds) {
  //                           final existing = await supabase
  //                               .from('inventory')
  //                               .select('inventory_id, quantity')
  //                               .eq('product_id', productId)
  //                               .eq('location_id', locationId)
  //                               .maybeSingle();

  //                           if (existing != null) {
  //                             final int currentQty = existing['quantity'] ?? 0;
  //                             await supabase
  //                                 .from('inventory')
  //                                 .update({'quantity': currentQty + units})
  //                                 .eq('inventory_id', existing['inventory_id']);
  //                           } else {
  //                             await supabase.from('inventory').insert({
  //                               'product_id': productId,
  //                               'location_id': locationId,
  //                               'quantity': units,
  //                             });
  //                           }
  //                         }

  //                         // Update the product's stock
  //                         await supabase
  //                             .from('products')
  //                             .update({
  //                               'stock': availableStock - totalRequiredStock,
  //                             })
  //                             .eq('product_id', productId);

  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text("Product assigned successfully"),
  //                           ),
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.blue.shade700,
  //                         foregroundColor: Colors.white,
  //                       ),
  //                       child: const Text("Assign"),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  void _showTransferSheet(BuildContext context) async {
    final supabase = Supabase.instance.client;

    final locations = await supabase.from('Locations').select('id, title');
    final categories = await supabase
        .from('categories')
        .select('category_id, category_name')
        .eq('archived', false);

    final products = await supabase
        .from('products')
        .select('product_id, product_name')
        .eq('archived', false);

    if (locations.isEmpty || categories.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Required data is missing.")),
      );
      return;
    }

    Map<String, dynamic>? selectedFromLocation = locations.first;
    Map<String, dynamic>? selectedToLocation = locations.length > 1
        ? locations[1]
        : locations.first;
    Map<String, dynamic>? selectedCategory = categories.first;
    Map<String, dynamic>? selectedProduct = products.first;

    final unitsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +30,
          left: 30,
          right: 30,
          top: 34,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Wrap(
            children: [
               Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transfer Units",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 25),
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<Map<String, dynamic>>(
        isExpanded: true, // Allows full width for dropdown
        value: selectedFromLocation,
        items: locations.map((loc) {
          return DropdownMenuItem(
            value: loc,
            child: Text(
              loc['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => selectedFromLocation = val),
        decoration: InputDecoration(
          hintText: "From",
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: DropdownButtonFormField<Map<String, dynamic>>(
        isExpanded: true,
        value: selectedToLocation,
        items: locations.map((loc) {
          return DropdownMenuItem(
            value: loc,
            child: Text(
              loc['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => selectedToLocation = val),
        decoration: InputDecoration(
          hintText: "To",
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  ],
),

  
    //           // From and To Locations
    //           Row(
    //             children: [
    //               Expanded(
    //                 child: DropdownButtonFormField<Map<String, dynamic>>(
    //                   value: selectedFromLocation,
    //                   items: locations.map((loc) {
    //                     return DropdownMenuItem(
    //                       value: loc,
    //                       child: Text(
    //                         loc['title'],
    //                         style: const TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,softWrap: true,
    //                       ),
    //                     );
    //                   }).toList(),
    //                   onChanged: (val) =>
    //                       setState(() => selectedFromLocation = val),
    //                   decoration: InputDecoration(
    //                     hintText: "From",
    //                     filled: true,
    //                     fillColor: Colors.grey.shade100,
    //                     border: OutlineInputBorder(
    //                       borderSide: BorderSide(
    //                           color: Colors.grey.shade300, // lighter grey border
    // width: 1.0, // optional: you can make it thinner or thicker
    //                       ),
    //                       borderRadius: BorderRadius.circular(8),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               const SizedBox(width: 12),
    //               Expanded(
    //                 child: DropdownButtonFormField<Map<String, dynamic>>(
    //                   value: selectedToLocation,
    //                   items: locations.map((loc) {
    //                     return DropdownMenuItem(
    //                       value: loc,
    //                       child: Text(
    //                         loc['title'],
    //                         style: const TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,softWrap: true,
    //                       ),
    //                     );
    //                   }).toList(),
    //                   onChanged: (val) =>
    //                       setState(() => selectedToLocation = val),
    //                   decoration: InputDecoration(
    //                     hintText: "To",
    //                     filled: true,
    //                     fillColor: Colors.grey.shade100,
    //                     border: OutlineInputBorder(
    //                       borderSide: BorderSide(
    //                           color: Colors.grey.shade300, // lighter grey border
    // width: 1.0, // optional: you can make it thinner or thicker
    //                       ),
    //                       borderRadius: BorderRadius.circular(8),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
             
             
              const SizedBox(height: 16),

              // Category Dropdown (optional use)
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat['category_name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                decoration: InputDecoration(
                  hintText: "Category",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
    width: 1.0, // optional: you can make it thinner or thicker
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Dropdown
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedProduct,
                items: products.map((prod) {
                  return DropdownMenuItem(
                    value: prod,
                    child: Text(prod['product_name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedProduct = val),
                decoration: InputDecoration(
                  hintText: "Product",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
    width: 1.0, // optional: you can make it thinner or thicker
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

             
              TextField(
                controller: unitsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                              color: Colors.grey.shade300, // lighter grey border
    width: 1.0, // optional: you can make it thinner or thicker
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
],
),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",style: TextStyle(color: const Color(0xFF0057FF), ),),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final fromId = selectedFromLocation?['id'];
                      final toId = selectedToLocation?['id'];
                      final productId = selectedProduct?['product_id'];
                      final int? units = int.tryParse(unitsController.text);

                      if (fromId == null ||
                          toId == null ||
                          productId == null ||
                          units == null ||
                          units <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fill all fields properly."),
                          ),
                        );
                        return;
                      }

                      if (fromId == toId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Locations must be different."),
                          ),
                        );
                        return;
                      }

                      final fromInventory = await supabase
                          .from('inventory')
                          .select('inventory_id, quantity')
                          .eq('location_id', fromId)
                          .eq('product_id', productId)
                          .maybeSingle();

                      final toInventory = await supabase
                          .from('inventory')
                          .select('inventory_id, quantity')
                          .eq('location_id', toId)
                          .eq('product_id', productId)
                          .maybeSingle();

                      if (fromInventory == null ||
                          (fromInventory['quantity'] ?? 0) < units) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Not enough stock to transfer."),
                          ),
                        );
                        return;
                      }

                      // Subtract from source location
                      await supabase
                          .from('inventory')
                          .update({
                            'quantity':
                                (fromInventory['quantity'] ?? 0) - units,
                          })
                          .eq('inventory_id', fromInventory['inventory_id']);

                      // Add to destination location
                      if (toInventory != null) {
                        await supabase
                            .from('inventory')
                            .update({
                              'quantity':
                                  (toInventory['quantity'] ?? 0) + units,
                            })
                            .eq('inventory_id', toInventory['inventory_id']);
                      } else {
                        await supabase.from('inventory').insert({
                          'product_id': productId,
                          'location_id': toId,
                          'quantity': units,
                        });
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Units transferred successfully."),
                        ),
                      );
                    },
                    
                    
                    child: const Text("Transfer",style: TextStyle(color:  const Color(0xFF0057FF),)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search by Product",
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductSheet(context),
                        icon: Icon(Icons.add),
                        label: Text("Add Product"),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF0057FF),
                          ),
                          backgroundColor: const Color(0xFFE4E8F3),
                          foregroundColor: const Color(0xFF0057FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                      // ElevatedButton.icon(

                      //   onPressed: () {
                      //     _showAddProductSheet(context);
                      //   },
                      //   icon: const Icon(Icons.add),
                      //   label: const Text("Add Product"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.black,
                      //     foregroundColor: Colors.white,
                      //   ),
                      // ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showTransferSheet(context),
                        icon: Icon(Icons.add),
                        label: Text("Transfer Units"),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF0057FF),
                          ),
                          backgroundColor: const Color(0xFFE4E8F3),
                          foregroundColor: const Color(0xFF0057FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     _showTransferSheet(context);
                      //   },
                      //   icon: const Icon(Icons.add),
                      //   label: const Text("Transfer Units"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: const Color.fromARGB(
                      //       255,
                      //       11,
                      //       110,
                      //       14,
                      //     ),
                      //     foregroundColor: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 10,),
Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [

Container(
  width: 230,
  margin: EdgeInsets.all(3),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    color: Colors.white,
  ),
                    
                    child: Row(
                      
                      children: [
                        SizedBox(width: 5,
                        ),
                        //             ElevatedButton.icon(
                        //   onPressed: () {
                        //     showActive = false;

                        //   },
                        //   icon: Icon(Icons.shield),
                        //   label: Text("Active"),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: !showActive? const Color(0xFF0057FF): const Color(0xFFF1F4F9),
                        //     foregroundColor: !showActive?  Colors.white:Colors.grey,
                        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        //   ),
                        // ),
                        // SizedBox(width: 8),
                        // OutlinedButton.icon(
                        //   onPressed: () {
                        //     showActive=true;

                        //   },
                        //   style: OutlinedButton.styleFrom(
                        //     backgroundColor: showActive?const Color(0xFF0057FF):const Color(0xFFF1F4F9) ,
                        //     foregroundColor:showActive? Colors.white :Colors.grey,
                        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        //   ),
                        //   icon: Icon(Icons.folder_zip_sharp),
                        //   label: Text("Archived"),
                        //   // style: OutlinedButton.styleFrom(
                        //   //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        //   // ),
                        // ),
                        TextButton.icon(
                          onPressed: () => setState(() => showActive = true),
                          style: TextButton.styleFrom(
                            backgroundColor: showActive
                                ? const Color(0xFF0057FF)
                                : const Color(0xFFF1F4F9),
                            foregroundColor: showActive
                                ? Colors.white
                                : Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: Icon(
                            Icons.shield,
                            color: showActive ? Colors.white : Colors.grey,
                          ),
                          label: Text(
                            "Active ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: showActive ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                         SizedBox(width: 3),
                        TextButton.icon(
                          onPressed: () => setState(() => showActive = false),
                          icon: Icon(
                            Icons.delete_outline,
                            color: !showActive ? Colors.white : Colors.grey,
                          ),
                          label: Text(
                            "Archived",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !showActive ? Colors.white : Colors.grey,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: !showActive
                                ? const Color(0xFF0057FF)
                                : const Color(0xFFF1F4F9),
                            foregroundColor: !showActive
                                ? Colors.white
                                : Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
  ],
),

                  buildProductCards(
                    showActive
                        ? filteredActiveProducts
                        : filteredAssignProducts,
                  ),
                ],
              ),
            ),
    );
  }
}
