import 'package:dio/dio.dart';
import 'package:music_tech/core/models/search_model.dart';

const baseUrl = "https://music-tech-rho.vercel.app";
// const baseUrl = "http://192.168.1.107:8080";

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    // _dio.interceptors.add(_AuthInterceptor());
    // _dio.interceptors.add(_ResponseInterceptor());
  }
  Future<List<SearchModel>> searchSongs(
    String query, [
    String type = 'ALL',
  ]) async {
    try {
      var url = '/search/$type?query=$query';
      final Response response = await _dio.get(url);
      final List<dynamic> data = response.data['data'];
      final dataList = data.map((ele) => SearchModel.fromMap(ele)).toList();
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchModel>> getPlayListById(String id) async {
    try {
      var url = '/playlist/$id';
      final Response response = await _dio.get(url);
      final List<dynamic> data = response.data['data'];
      final dataList = data.map((ele) => SearchModel.fromMap(ele)).toList();
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<SearchModel?> getArtistById(String artistId) async {
    try {
      var url = '/artist/$artistId';
      final Response response = await _dio.get(url);
      final data = response.data['data'];
      return SearchModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }
}
