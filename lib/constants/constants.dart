const BASE_URL = '192.168.1.2:8080';

const filmsApi = '/api/v1/films';
const loginApi = '/api/v1/login';

const requestTimeOut  = 90;

class Globals {

  static String _session;

  static set session(String session) => _session = session;

  static get sessionToken =>  _session;

}
