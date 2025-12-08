import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'WorkShift'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit Employee'**
  String get editEmployee;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @addShift.
  ///
  /// In en, this message translates to:
  /// **'Add Shift'**
  String get addShift;

  /// No description provided for @editShift.
  ///
  /// In en, this message translates to:
  /// **'Edit Shift'**
  String get editShift;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee Name'**
  String get employeeName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Price Per Day'**
  String get pricePerDay;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select Employee'**
  String get selectEmployee;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @shiftType.
  ///
  /// In en, this message translates to:
  /// **'Shift Type'**
  String get shiftType;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get allDay;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @advanceMoney.
  ///
  /// In en, this message translates to:
  /// **'Advance Money'**
  String get advanceMoney;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get noEmployees;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClients;

  /// No description provided for @noShifts.
  ///
  /// In en, this message translates to:
  /// **'No shifts yet'**
  String get noShifts;

  /// No description provided for @totalShifts.
  ///
  /// In en, this message translates to:
  /// **'Total Shifts'**
  String get totalShifts;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @totalAdvances.
  ///
  /// In en, this message translates to:
  /// **'Total Advances'**
  String get totalAdvances;

  /// No description provided for @balanceToPay.
  ///
  /// In en, this message translates to:
  /// **'Balance to Pay'**
  String get balanceToPay;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @last15Days.
  ///
  /// In en, this message translates to:
  /// **'Last 15 Days'**
  String get last15Days;

  /// No description provided for @next15Days.
  ///
  /// In en, this message translates to:
  /// **'Next 15 Days'**
  String get next15Days;

  /// No description provided for @recentShifts.
  ///
  /// In en, this message translates to:
  /// **'Recent Shifts'**
  String get recentShifts;

  /// No description provided for @workingToday.
  ///
  /// In en, this message translates to:
  /// **'Working Today'**
  String get workingToday;

  /// No description provided for @totalStaff.
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get totalStaff;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get activeClients;

  /// No description provided for @employeeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Employee Statistics'**
  String get employeeStatistics;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @scheduleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Schedule Calendar'**
  String get scheduleCalendar;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @downloadExcel.
  ///
  /// In en, this message translates to:
  /// **'Download Excel'**
  String get downloadExcel;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @generateEmployeeReports.
  ///
  /// In en, this message translates to:
  /// **'Generate employee reports'**
  String get generateEmployeeReports;

  /// No description provided for @selectEmployeeToGenerateReports.
  ///
  /// In en, this message translates to:
  /// **'Please select an employee to generate reports'**
  String get selectEmployeeToGenerateReports;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @aboutWorkShift.
  ///
  /// In en, this message translates to:
  /// **'About WorkShift'**
  String get aboutWorkShift;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @createNewClient.
  ///
  /// In en, this message translates to:
  /// **'Create a new client'**
  String get createNewClient;

  /// No description provided for @updateClientInformation.
  ///
  /// In en, this message translates to:
  /// **'Update client information'**
  String get updateClientInformation;

  /// No description provided for @enterClientName.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get enterClientName;

  /// No description provided for @pleaseEnterClientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter client name'**
  String get pleaseEnterClientName;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @updateClient.
  ///
  /// In en, this message translates to:
  /// **'Update Client'**
  String get updateClient;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterEmployeeName.
  ///
  /// In en, this message translates to:
  /// **'Please enter employee name'**
  String get pleaseEnterEmployeeName;

  /// No description provided for @enterDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Enter daily rate'**
  String get enterDailyRate;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @pleaseEnterPricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Please enter price per day'**
  String get pleaseEnterPricePerDay;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneNumberOptional;

  /// No description provided for @updateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Update Employee'**
  String get updateEmployee;

  /// No description provided for @allFieldsMarkedRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields marked with * are required'**
  String get allFieldsMarkedRequired;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @clientOptional.
  ///
  /// In en, this message translates to:
  /// **'Client (Optional)'**
  String get clientOptional;

  /// No description provided for @noClient.
  ///
  /// In en, this message translates to:
  /// **'No Client'**
  String get noClient;

  /// No description provided for @noEmployeesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No employees available'**
  String get noEmployeesAvailable;

  /// No description provided for @cannotAddShift.
  ///
  /// In en, this message translates to:
  /// **'Cannot add shift: All Day shift conflicts with other shifts'**
  String get cannotAddShift;

  /// No description provided for @shiftConflictDetected.
  ///
  /// In en, this message translates to:
  /// **'Shift conflict detected'**
  String get shiftConflictDetected;

  /// No description provided for @pleaseSelectEmployee.
  ///
  /// In en, this message translates to:
  /// **'Please select an employee'**
  String get pleaseSelectEmployee;

  /// No description provided for @enterAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter advance amount'**
  String get enterAdvanceAmount;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotes;

  /// No description provided for @updateShift.
  ///
  /// In en, this message translates to:
  /// **'Update Shift'**
  String get updateShift;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @fourHours.
  ///
  /// In en, this message translates to:
  /// **'4 hours'**
  String get fourHours;

  /// No description provided for @eightHours.
  ///
  /// In en, this message translates to:
  /// **'8 hours'**
  String get eightHours;

  /// No description provided for @zeroHours.
  ///
  /// In en, this message translates to:
  /// **'0 hours'**
  String get zeroHours;

  /// No description provided for @allEmployees.
  ///
  /// In en, this message translates to:
  /// **'All Employees'**
  String get allEmployees;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'result'**
  String get result;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noEmployeesFound.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get noEmployeesFound;

  /// No description provided for @startByAddingFirstEmployee.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first employee'**
  String get startByAddingFirstEmployee;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @searchEmployeesByName.
  ///
  /// In en, this message translates to:
  /// **'Search employees by name...'**
  String get searchEmployeesByName;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @totalShiftsLabel.
  ///
  /// In en, this message translates to:
  /// **'total shifts'**
  String get totalShiftsLabel;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @searchClientsByNameOrLocation.
  ///
  /// In en, this message translates to:
  /// **'Search clients by name or location...'**
  String get searchClientsByNameOrLocation;

  /// No description provided for @allClients.
  ///
  /// In en, this message translates to:
  /// **'All Clients'**
  String get allClients;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClientsFound;

  /// No description provided for @startByAddingFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first client'**
  String get startByAddingFirstClient;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Report Summary'**
  String get reportSummary;

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @exportAllDataToFile.
  ///
  /// In en, this message translates to:
  /// **'Export all data to file'**
  String get exportAllDataToFile;

  /// No description provided for @importDataFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Import data from backup'**
  String get importDataFromBackup;

  /// No description provided for @restoreFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Restore feature coming soon!'**
  String get restoreFeatureComingSoon;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @areYouSureDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all employees, clients, and shifts? This action cannot be undone.'**
  String get areYouSureDeleteAll;

  /// No description provided for @totalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get totalEmployees;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @employeeManagement.
  ///
  /// In en, this message translates to:
  /// **'Employee management'**
  String get employeeManagement;

  /// No description provided for @clientManagement.
  ///
  /// In en, this message translates to:
  /// **'Client management'**
  String get clientManagement;

  /// No description provided for @shiftScheduling.
  ///
  /// In en, this message translates to:
  /// **'Shift scheduling'**
  String get shiftScheduling;

  /// No description provided for @conflictDetection.
  ///
  /// In en, this message translates to:
  /// **'Conflict detection'**
  String get conflictDetection;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get calendarView;

  /// No description provided for @darkModeSupport.
  ///
  /// In en, this message translates to:
  /// **'Dark mode support'**
  String get darkModeSupport;

  /// No description provided for @modernShiftWorkCalendar.
  ///
  /// In en, this message translates to:
  /// **'A modern shift work calendar management system for managing employee schedules, clients, and shifts efficiently.'**
  String get modernShiftWorkCalendar;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @employeeReport.
  ///
  /// In en, this message translates to:
  /// **'Employee Report'**
  String get employeeReport;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @excelFileSaved.
  ///
  /// In en, this message translates to:
  /// **'Excel file saved'**
  String get excelFileSaved;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @errorGeneratingExcel.
  ///
  /// In en, this message translates to:
  /// **'Error generating Excel'**
  String get errorGeneratingExcel;

  /// No description provided for @pdfGeneratedReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'PDF generated and ready to share'**
  String get pdfGeneratedReadyToShare;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF'**
  String get errorGeneratingPdf;

  /// No description provided for @employeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employeeLabel;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @deleteAllEmployeesClientsShifts.
  ///
  /// In en, this message translates to:
  /// **'Delete all employees, clients, and shifts'**
  String get deleteAllEmployeesClientsShifts;

  /// No description provided for @manageYourTeamShiftsEfficiently.
  ///
  /// In en, this message translates to:
  /// **'Manage your team shifts efficiently'**
  String get manageYourTeamShiftsEfficiently;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @checkForNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Check for new version'**
  String get checkForNewVersion;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates. Please try again later.'**
  String get updateCheckFailed;

  /// No description provided for @appIsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date!'**
  String get appIsUpToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get newVersionAvailable;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes'**
  String get releaseNotes;

  /// No description provided for @forceUpdateRequired.
  ///
  /// In en, this message translates to:
  /// **'This update is required to continue using the app.'**
  String get forceUpdateRequired;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @cannotOpenDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'Cannot open download link. Please check your internet connection.'**
  String get cannotOpenDownloadLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
