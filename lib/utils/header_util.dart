class NetworkHelper {

  static Map<String, String> getHeader(String session) {
    Map<String, String> header = {
      'Content-type':'application/json',
      'Accept':'application/json'
    };
    if (session != null) {
      header['Authorization'] = 'Bearer $session';
    } else {
      print(' Session missing!');
    }
    return header;
  }

}