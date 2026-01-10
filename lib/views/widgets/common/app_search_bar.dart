import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final int filterCount;
  final bool isSortedAscending;
  final Duration debounceDuration;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search recipes...',
    this.onChanged,
    this.onFilterTap,
    this.onSortTap,
    this.filterCount = 0,
    this.isSortedAscending = true,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(query);
    });
    setState(() {}); // Rebuild to show/hide clear button
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(_isFocused ? 1.02 : 1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? AppColors.grey : AppColors.midGrey,
          width: 2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.lightGrey,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? AppColors.white : AppColors.grey,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.grey,
                  onPressed: _clearSearch,
                ),
              if (widget.onSortTap != null) ...[
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.midGrey,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: widget.isSortedAscending ? 0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.sort_by_alpha_rounded),
                  ),
                  color: AppColors.grey,
                  onPressed: widget.onSortTap,
                  tooltip: widget.isSortedAscending ? 'A-Z' : 'Z-A',
                ),
              ],
              if (widget.onFilterTap != null) ...[
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.midGrey,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.tune_rounded),
                      if (widget.filterCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '${widget.filterCount}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  color: AppColors.grey,
                  onPressed: widget.onFilterTap,
                ),
              ],
            ],
          ),
          filled: true,
          fillColor: AppColors.darkGrey,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
