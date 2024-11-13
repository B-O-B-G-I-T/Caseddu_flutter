import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    required this.onChanged,
    required this.searchController,
  });
  final ValueChanged<String> onChanged;
  final TextEditingController searchController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        ),
        onTap: () => searchController.clear(),
        onChanged: onChanged,
      ),
    );
  }
}
