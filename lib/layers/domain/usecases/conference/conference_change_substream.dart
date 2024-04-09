import 'package:janus_client/janus_client.dart';

import '../../repos/conference_repo.dart';

class ConferenceChangeSubStream {

  ConferenceChangeSubStream({required  this.repo});

  final ConferenceRepo repo;


  call( ConfigureStreamQuality quality) {
    repo.changeSubStream(quality: quality);
  }
}
