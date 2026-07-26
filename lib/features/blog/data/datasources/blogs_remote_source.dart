import 'dart:convert';

import 'package:tisini/core/constants/api_constants.dart';

import 'package:tisini/core/services/http_service.dart';

abstract interface class BlogsRemoteSource {
  Future<String> getCategoryBlogs();
}

class BlogsRemoteSourceImpl implements BlogsRemoteSource {
  final HttpService _httpService;

  BlogsRemoteSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<String> getCategoryBlogs() async {
    print("${ApiConstants.apiblogsURL}/category_articles/");
    final response = await _httpService.get(
      "${ApiConstants.apiblogsURL}/category_articles/",
    );

    print(response);

    return "Blogs fetched successfully";
  }
}
