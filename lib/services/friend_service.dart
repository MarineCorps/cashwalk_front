import 'dart:async';
import 'dart:convert';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/models/ranking_user.dart';
import 'package:cashwalk/models/friend_request_result.dart';
import 'package:cashwalk/models/friend_search_result.dart';
import 'package:cashwalk/models/recommended_user.dart';
import 'package:cashwalk/models/blocked_user.dart';
import 'package:cashwalk/models/friend_user.dart';
import 'package:cashwalk/services/http_service.dart';

class FriendService {
  static final _friendListController = StreamController<List<RankingUser>>.broadcast();
  static final _friendRequestController = StreamController<List<FriendRequestResult>>.broadcast();

  static Stream<List<RankingUser>> get friendListStream => _friendListController.stream;
  static Stream<List<FriendRequestResult>> get friendRequestStream => _friendRequestController.stream;

  static Future<void> refreshFriendList({String? query}) async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final endpoint = '/api/friends/list${query != null ? '?query=$query' : ''}';
    final data = await HttpService.getFromServer(endpoint, headers: headers);
    _friendListController.add((data as List).map((e) => RankingUser.fromJson(e)).toList());
  }

  static Future<List<FriendUser>> getMyFriends({String? query}) async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final endpoint = '/api/friends/list${query != null && query.isNotEmpty ? '?nickname=$query' : ''}';
    final data = await HttpService.getFromServer(endpoint, headers: headers);
    return (data as List).map((e) => FriendUser.fromJson(e)).toList();
  }

  static Future<void> refreshFriendRequests() async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final received = await HttpService.getFromServer('/api/friends/requests/received', headers: headers);
    final sent = await HttpService.getFromServer('/api/friends/requests/sent', headers: headers);

    final all = [...received, ...sent]
        .map<FriendRequestResult>((e) => FriendRequestResult.fromJson(e))
        .toList();

    _friendRequestController.add(all);
  }

  static Future<bool> acceptFriendRequest(int senderId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    await HttpService.postToServer(
      '/api/friends/requests/accept',
      {'senderId': senderId},
      headers: headers,
    );

    await refreshFriendList();
    await refreshFriendRequests();
    return true;
  }

  static Future<bool> rejectFriendRequest(int senderId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    await HttpService.postToServer(
      '/api/friends/requests/reject',
      {'senderId': senderId},
      headers: headers,
    );
    await refreshFriendRequests();
    return true;
  }

  static Future<bool> sendFriendRequest(int receiverId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    await HttpService.postToServer(
      '/api/friends/requests/send',
      {'receiverId': receiverId},
      headers: headers,
    );
    return true;
  }

  static Future<FriendSearchResult?> searchUserByInviteCode(String code) async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final res = await HttpService.getFromServer('/api/friends/search?inviteCode=$code', headers: headers);
      return FriendSearchResult.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  static Future<List<RecommendedUser>> getRecommendedFriends() async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final data = await HttpService.getFromServer('/api/friends/recommend', headers: headers);
    return (data as List).map((e) => RecommendedUser.fromJson(e)).toList();
  }

  static Future<List<BlockedUser>> getBlockedUsers() async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final data = await HttpService.getFromServer('/api/friends/blocked', headers: headers);
    return (data as List).map((e) => BlockedUser.fromJson(e)).toList();
  }

  static Future<bool> unblockUser(int userId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    await HttpService.postToServer(
      '/api/friends/unblock',
      {'userId': userId},
      headers: headers,
    );
    return true;
  }

  static Future<void> deleteFriend(int friendId) async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    await HttpService.deleteFromServer('/api/friends/delete/$friendId', headers: headers);
  }
}
