import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DoctorProfile parses backend JSON', () {
    final json = <String, dynamic>{
      'id': 'd1',
      'mobile': '919876543210',
      'first_name': 'Asha',
      'middle_name': null,
      'last_name': 'Rao',
      'email': null,
      'educations': <Map<String, dynamic>>[
        {
          'id': 'e1',
          'degree': 'MBBS',
          'registration_number': 'R1',
          'institution': null,
          'year_of_completion': null,
        },
      ],
      'specialities': <Map<String, dynamic>>[
        {'id': 's1', 'name': 'Cardiology'},
      ],
      'experiences': <Map<String, dynamic>>[],
      'profile_completion': 40,
      'sections': <String, bool>{
        'personal': true,
        'education': true,
        'speciality': true,
        'experience': false,
        'working_hours': false,
      },
    };
    final p = DoctorProfile.fromJson(json);
    expect(p.profileCompletion, 40);
    expect(p.educations.single.degree, 'MBBS');
    expect(p.sections['experience'], false);
  });
}
