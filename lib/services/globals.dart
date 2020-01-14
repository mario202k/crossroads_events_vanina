import 'services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


/// Static global state. Immutable services that do not care about build context. 
class Global {
  // App Data
  static final String title = 'Fireship';

  // Services
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

    // Data Models
  static final Map models = {
    //Report: (data) => Report.fromMap(data),
  };

  // Firestore References for Writes
  static final Collection<MonEvent> eventsRef = Collection<MonEvent>(path: 'events');
  //static final UserData<Report> reportRef = UserData<Report>(collection: 'reports');

  
}
