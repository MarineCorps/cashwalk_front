import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegionSearchPage extends StatefulWidget {
  const RegionSearchPage({super.key});

  @override
  State<RegionSearchPage> createState() => _RegionSearchPageState();
}

class _RegionSearchPageState extends State<RegionSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> allRegions = [];
  List<dynamic> filteredRegions = [];
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    loadRegionData();
  }

  Future<void> loadRegionData() async {
    final String jsonString = await rootBundle.loadString('assets/regions.json');
    final List<dynamic> data = json.decode(jsonString);
    setState(() {
      allRegions = data;
    });
  }

  void search(String query) {
    setState(() {
      filteredRegions = allRegions.where((region) {
        final full = '${region["province"]} ${region["city"]} ${region["district"]}';
        return full.contains(query);
      }).toList();
    });
  }

  void selectRegion(String fullRegion) {
    if (!recentSearches.contains(fullRegion)) {
      setState(() {
        recentSearches.insert(0, fullRegion);
        if (recentSearches.length > 5) {
          recentSearches = recentSearches.sublist(0, 5); // 최근 5개까지만 저장
        }
      });
    }
    Navigator.pop(context, fullRegion); // 지역 선택하고 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 검색', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 키보드 정상 작동하는 검색창
            TextField(
              controller: _controller,
              enableIMEPersonalizedLearning: true, // 👈 한글 입력 정상화
              decoration: InputDecoration(
                hintText: '시/군/구, 읍/면/동 단위로 입력하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => search(value.trim()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _controller.text.isEmpty
                  ? _buildRecentSearches()
                  : _buildFilteredResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (recentSearches.isEmpty) {
      return const Center(
        child: Text('최근 검색한 지역이 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('최근 검색 지역', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...recentSearches.map((region) => ListTile(
          title: Text(region),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                recentSearches.remove(region);
              });
            },
          ),
          onTap: () => selectRegion(region),
        )),
      ],
    );
  }

  Widget _buildFilteredResults() {
    if (filteredRegions.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: filteredRegions.length,
      itemBuilder: (context, index) {
        final region = filteredRegions[index];
        final full = '${region["province"]} ${region["city"]} ${region["district"]}';
        return ListTile(
          title: Text(full),
          onTap: () => selectRegion(full),
        );
      },
    );
  }
}