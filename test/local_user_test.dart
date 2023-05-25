import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_escape_application/database/local_user.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalUser', () {
    test(
        'Controll that saveStopwatchTime can save time, loadStopwatchTime can load it and end it by reseting the time tracker',
        () async {
      SharedPreferences.setMockInitialValues({});

      // Start by checking that the loadStopwachTime is 0 before saveStopwatchTime is set to anything
      const expectedToBeZero = 0;
      final result = await LocalUser.loadStopwatchTime();
      expect(result, expectedToBeZero);

      // Set time to 6 minutes with saveStopwatchTime and then check if loadStopwatchTime is correct
      const expectedToBe6000 = 6000; //6000 milliseconds = 6 minutes
      await LocalUser.saveStopwatchTime(expectedToBe6000);
      final newResult = await LocalUser.loadStopwatchTime();
      expect(newResult, expectedToBe6000);

      //Now we will reset the time tracker and check that it is set to 0
      const expectedToBeZeroAgain = 0;
      await LocalUser.resetTimeTracker();
      final resultAfterReseting = await LocalUser.loadStopwatchTime();
      expect(resultAfterReseting, expectedToBeZeroAgain);
    });

    test(
        'loadRecordedTimeWeekday should load recorded time for a given weekday and then resetRecordedTimeWeekday',
        () async {
      // Not setting any values so that we have a default of 0 and checking that the loadedRecordedTime is 0 for the weekdays
      SharedPreferences.setMockInitialValues({});

      final mondayTime = await LocalUser().loadRecordedTimeWeekday(1);
      final tuesdayTime = await LocalUser().loadRecordedTimeWeekday(2);
      final wednesdayTime = await LocalUser().loadRecordedTimeWeekday(3);
      final thursdayTime = await LocalUser().loadRecordedTimeWeekday(4);
      final fridayTime = await LocalUser().loadRecordedTimeWeekday(5);
      final saturdayTime = await LocalUser().loadRecordedTimeWeekday(6);
      final sundayTime = await LocalUser().loadRecordedTimeWeekday(7);

      expect(mondayTime, 0);
      expect(tuesdayTime, 0);
      expect(wednesdayTime, 0);
      expect(thursdayTime, 0);
      expect(fridayTime, 0);
      expect(saturdayTime, 0);
      expect(sundayTime, 0);

      //Setting different values to loadRecordedTimeWeekday for different days and checking the values
      const mondayTotalTime = 5000;
      const tuesdayTotalTime = 200;
      const wednesdayTotalTime = 10000;
      const thursdayTotalTime = 124521;
      const fridayTotalTime = 651651651;
      const saturdayTotalTime = 18153;
      const sundayTotalTime = 21685165;

      SharedPreferences.setMockInitialValues({
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '1'): mondayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '2'):
            tuesdayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '3'):
            wednesdayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '4'):
            thursdayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '5'): fridayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '6'):
            saturdayTotalTime,
        LocalUser.timeSpentInDayKey.replaceAll('weekday', '7'): sundayTotalTime,
      });

      final newMondayTime = await LocalUser().loadRecordedTimeWeekday(1);
      final newTuesdayTime = await LocalUser().loadRecordedTimeWeekday(2);
      final newWednesdayTime = await LocalUser().loadRecordedTimeWeekday(3);
      final newThursdayTime = await LocalUser().loadRecordedTimeWeekday(4);
      final newFridayTime = await LocalUser().loadRecordedTimeWeekday(5);
      final newSaturdayTime = await LocalUser().loadRecordedTimeWeekday(6);
      final newSundayTime = await LocalUser().loadRecordedTimeWeekday(7);

      expect(newMondayTime, mondayTotalTime);
      expect(newTuesdayTime, tuesdayTotalTime);
      expect(newWednesdayTime, wednesdayTotalTime);
      expect(newThursdayTime, thursdayTotalTime);
      expect(newFridayTime, fridayTotalTime);
      expect(newSaturdayTime, saturdayTotalTime);
      expect(newSundayTime, sundayTotalTime);

      //Now we will check if the resetRecordedTimeWeekday works and it should remove all the stored recorded time
      await LocalUser.resetRecordedTimeWeekday();

      final afterResetMondayTime = await LocalUser().loadRecordedTimeWeekday(1);
      final afterResetTuesdayTime =
          await LocalUser().loadRecordedTimeWeekday(2);
      final afterResetWednesdayTime =
          await LocalUser().loadRecordedTimeWeekday(3);
      final afterResetThursdayTime =
          await LocalUser().loadRecordedTimeWeekday(4);
      final afterResetFridayTime = await LocalUser().loadRecordedTimeWeekday(5);
      final afterResetSaturdayTime =
          await LocalUser().loadRecordedTimeWeekday(6);
      final afterResetSundayTime = await LocalUser().loadRecordedTimeWeekday(7);

      expect(afterResetMondayTime, equals(0));
      expect(afterResetTuesdayTime, equals(0));
      expect(afterResetWednesdayTime, equals(0));
      expect(afterResetThursdayTime, equals(0));
      expect(afterResetFridayTime, equals(0));
      expect(afterResetSaturdayTime, equals(0));
      expect(afterResetSundayTime, equals(0));
    });

    test(
        'Testing that lastDayAppWasOpened() returns empty String in beginning and then returns entered value',
        () async {
      SharedPreferences.setMockInitialValues({});

      const expectedAnswerIsEmptyString = '';

      //Call the lastDayAppWasOpened()
      final neverOpenedBefore = await LocalUser.lastDayAppWasOpened();

      expect(neverOpenedBefore, expectedAnswerIsEmptyString);

      // Set inital value for 'last_opened_day' in SharedPreferences
      const initialLastOpenedDay = '2023-05-23';
      SharedPreferences.setMockInitialValues({
        'last_opened_day': initialLastOpenedDay,
      });

      //Call the lastDayAppWasOpened()
      final lastOpenedDay = await LocalUser.lastDayAppWasOpened();

      expect(lastOpenedDay, initialLastOpenedDay);
    });

    test('Testing save and loadWeeklyGoal with different values', () async {
      //First checking that loadWeeklyGoal is empty because no inital values are set
      SharedPreferences.setMockInitialValues({});
      const expectedToBeZero = 0;
      final result = await LocalUser.loadWeeklyGoal();
      expect(result, expectedToBeZero);

      //Setting the weeklyGoal to 55 minutes by using the weeklyGoalKey that is in the saveWeeklyGoal()
      int expectedWeeklyGoal = 5500;
      //Expectedweeklygoal is set
      await LocalUser.saveWeeklyGoal(expectedWeeklyGoal);
      final newResult = await LocalUser.loadWeeklyGoal();
      expect(newResult, expectedWeeklyGoal);
    });

    test('saveMarkers should save markers to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      //Will start by loading loadData() and checking if it is empty
      LocalUser().loadMarkers(prefs);
      final listThatIsUpdatedAfterPreviousMethod = LocalUser.savedMarkers;
      expect(listThatIsUpdatedAfterPreviousMethod, equals(List.empty()));

      // Set up the data
      final savedMarkers = {
        const Marker(
          markerId: MarkerId('marker1'),
          position: LatLng(1.0, 2.0),
          infoWindow: InfoWindow(title: 'Marker 1'),
        ),
        const Marker(
          markerId: MarkerId('marker2'),
          position: LatLng(3.0, 4.0),
          infoWindow: InfoWindow(title: 'Marker 2'),
        ),
      };

      LocalUser.savedMarkers = savedMarkers.toSet();

      LocalUser().saveMarkers(prefs);

      // Verify that the correct data is saved to SharedPreferences
      final expectedMarkersJson = json.encode([
        {
          'markerId': 'marker1',
          'latitude': 1.0,
          'longitude': 2.0,
          'infoWindowTitle': 'Marker 1',
        },
        {
          'markerId': 'marker2',
          'latitude': 3.0,
          'longitude': 4.0,
          'infoWindowTitle': 'Marker 2',
        },
      ]);

      final savedMarkersJson = prefs.getString('saved_markers');
      expect(savedMarkersJson, expectedMarkersJson);

      //Call the method to load the data again
      LocalUser().loadMarkers(prefs);

      final loadedMarkers = LocalUser.savedMarkers;
      // Verify that each expected marker exists in the loaded markers set
      for (final expectedMarker in savedMarkers) {
        expect(
          loadedMarkers,
          contains(predicate<Marker>((marker) {
            return marker.markerId == expectedMarker.markerId &&
                marker.position == expectedMarker.position &&
                marker.infoWindow.title == expectedMarker.infoWindow.title;
          })),
        );
      }
    });

    test(
        'check that the setGoalAchievementPopUp is only true once and never again',
        () async {
      //First we will not set an inital value so that popup flag should be false
      SharedPreferences.setMockInitialValues({});
      const bool expectedToBeFalse = false;
      final result = await LocalUser.getGoalAchievementPopupShown();
      expect(result, expectedToBeFalse);
      expect(LocalUser.goalAchievementPopUpHasBeenShown, equals(false));

      //Now we will set the achievement to true and see if the returned value has changed from earlier
      const bool expectedToBeTrue = true;
      await LocalUser.setGoalAchievementPopupShown(true);
      final newResult = await LocalUser.getGoalAchievementPopupShown();
      expect(newResult, expectedToBeTrue);
      expect(LocalUser.goalAchievementPopUpHasBeenShown, equals(true));
    });

    test(
        'check that the setTimerAchievementPopup is only true once and never again',
        () async {
      //First we will not set an inital value so that popup flag should be false
      SharedPreferences.setMockInitialValues({});
      const bool expectedToBeFalse = false;
      final result = await LocalUser.getTimerAchievementPopupShown();
      expect(result, expectedToBeFalse);
      expect(LocalUser.timerAchievementPopupShown, equals(false));

      //Now we will set the achievement to true and see if the returned value has changed from earlier
      const bool expectedToBeTrue = true;
      await LocalUser.setTimerAchievementPopupShown(true);
      final newResult = await LocalUser.getTimerAchievementPopupShown();
      expect(newResult, expectedToBeTrue);
      expect(LocalUser.timerAchievementPopupShown, equals(true));
    });

    test(
        'check that the setSoundAchievementPopup is only true once and never again',
        () async {
      //First we will not set an inital value so that popup flag should be false
      SharedPreferences.setMockInitialValues({});
      const bool expectedToBeFalse = false;
      final result = await LocalUser.getSoundAchievementPopupShown();
      expect(result, expectedToBeFalse);
      expect(LocalUser.soundsAchievementPopupShown, equals(false));

      //Now we will set the achievement to true and see if the returned value has changed from earlier
      const bool expectedToBeTrue = true;
      await LocalUser.setSoundsAchievementPopupShown(true);
      final newResult = await LocalUser.getSoundAchievementPopupShown();
      expect(newResult, expectedToBeTrue);
      expect(LocalUser.soundsAchievementPopupShown, equals(true));
    });

    test(
        'check that the setGoalReacherAchievementPopup is only true once and never again',
        () async {
      //First we will not set an inital value so that popup flag should be false
      SharedPreferences.setMockInitialValues({});
      const bool expectedToBeFalse = false;
      final result = await LocalUser.getGoalReacherAchievementPopupShown();
      expect(result, expectedToBeFalse);
      expect(LocalUser.goalReacherAchievementPopupShown, equals(false));

      //Now we will set the achievement to true and see if the returned value has changed from earlier
      const bool expectedToBeTrue = true;
      await LocalUser.setGoalReacherAchievementPopupShown(true);
      final newResult = await LocalUser.getGoalReacherAchievementPopupShown();
      expect(newResult, expectedToBeTrue);
      expect(LocalUser.goalReacherAchievementPopupShown, equals(true));
    });
  });
}
