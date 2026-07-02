import '../class/statusrequest.dart';

StatusRequest handlingData(dynamic response) {
  if (response is StatusRequest) return response;
  return StatusRequest.success;
}
