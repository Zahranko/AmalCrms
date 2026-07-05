// Bilingual support — English and Arabic.
// Usage: t('key') or t('key', { name: 'John' }) for string interpolation.
// Static HTML text: add data-i18n="key" (or data-i18n-placeholder / data-i18n-aria) to the element.
// Dynamic JS text: call t('key') inline when building strings.

const TRANSLATIONS = {
  en: {
    // NAV
    'nav.dashboard': 'Dashboard',
    'nav.newCase': 'New Case',
    'nav.cases': 'Cases',
    'nav.forwardedToMe': 'Forwarded to Me',
    'nav.forwardedByMe': 'Forwarded by Me',
    'nav.manageLists': 'Manage Lists',
    'nav.userManagement': 'User Management',
    'nav.hospitalReport': 'Hospital Report',
    'nav.contact': 'Contact',
    'nav.systemParams': 'System Parameters',

    // WEBSITE / MULTI-SITE
    'website.pickTitle': 'Choose a workspace',
    'website.pickSubtitle': "Select which website you'd like to work in.",
    'website.current': 'Current website: {name}',
    'login.noWebsiteAccess': 'Your account has no website access. Please contact your administrator.',
    'contact.title': 'Contact',
    'contact.comingSoon': 'This website is coming soon.',
    'userForm.websites': 'Website access',
    'userForm.websitesAdminNote': 'Admins can access every website.',
    'userForm.websitesNone': 'No websites available.',
    'systemParams.title': 'System Parameters',
    'systemParams.subtitle': 'Per-website settings for',
    'systemParams.add': '+ Add Parameter',
    'systemParams.loading': 'Loading parameters…',
    'systemParams.key': 'Key',
    'systemParams.value': 'Value',
    'systemParams.keyPlaceholder': 'e.g. supportPhone',
    'systemParams.valuePlaceholder': 'Value',
    'systemParams.empty': 'No parameters yet. Add one to get started.',
    'systemParams.saved': 'Saved.',
    'systemParams.duplicateKey': 'Duplicate keys are not allowed.',
    'systemParams.loadError': 'Could not load parameters.',
    'systemParams.saveError': 'Could not save parameters.',
    'action.delete': 'Delete',

    // TOPBAR
    'topbar.hi': 'Hi, {name}',
    'topbar.logout': 'Log out',
    'topbar.openMenu': 'Open menu',
    'topbar.closeMenu': 'Close menu',
    'topbar.notifications': 'Notifications',

    // LOGIN
    'login.title': 'Welcome back',
    'login.subtitle': 'Sign in to continue to your dashboard',
    'login.username': 'Username',
    'login.usernamePlaceholder': 'Enter your username',
    'login.password': 'Password',
    'login.passwordPlaceholder': 'Enter your password',
    'login.showPassword': 'Show password',
    'login.hidePassword': 'Hide password',
    'login.signIn': 'Sign In',
    'login.signingIn': 'Signing in...',
    'login.footer': 'Need an account? Contact your system administrator.',
    'login.brandTitle': 'Clinical Resource & Management System',
    'login.brandSubtitle': 'Secure access for hospital staff. Sign in with the credentials provided by your administrator.',
    'login.feature1': 'Patient & case records, always in sync',
    'login.feature2': 'Real-time monitoring for every department',
    'login.feature3': 'Role-based access, protected end to end',
    'login.errorEmpty': 'Please enter both username and password.',
    'login.errorGeneric': 'Something went wrong. Please try again.',

    // STATUS
    'status.pending': 'Pending',
    'status.waiting': 'Waiting',
    'status.success': 'Success',
    'status.failed': 'Failed',

    // ACTIVE STATE
    'state.active': 'Active',
    'state.disabled': 'Disabled',

    // ROLES
    'role.employee': 'Employee',
    'role.manager': 'Manager',
    'role.admin': 'Admin',
    'role.hospitalManager': 'Hospital Manager',

    // COMMON ACTIONS
    'action.view': 'View',
    'action.edit': 'Edit',
    'action.save': 'Save',
    'action.saving': 'Saving...',
    'action.cancel': 'Cancel',
    'action.confirm': 'Confirm',
    'action.add': 'Add',
    'action.enable': 'Enable',
    'action.disable': 'Disable',
    'action.close': 'Close',
    'action.assignToMe': 'Assign to Me',
    'action.assigning': 'Assigning…',
    'action.followUp': 'Follow-up',
    'action.forward': 'Forward',
    'action.accept': 'Accept',
    'action.decline': 'Decline',
    'action.reopen': 'Re-open',
    'action.markAllRead': 'Mark all read',
    'action.resetPassword': 'Reset Password',
    'action.addUser': '+ Add User',

    // LOADING / EMPTY
    'loading.cases': 'Loading cases…',
    'loading.users': 'Loading users…',
    'loading.case': 'Loading case…',
    'loading.stats': 'Loading statistics…',
    'loading.generic': 'Loading…',

    // SEARCH
    'search.placeholder': 'Search by name or phone…',
    'search.noMatch': 'No cases match your search.',

    // NOTIFICATIONS
    'notifications.title': 'Notifications',
    'notifications.markAllRead': 'Mark all read',
    'notifications.loading': 'Loading…',
    'notifications.empty': "You're all caught up.",
    'notifications.delete': 'Delete notification',

    // DASHBOARD — employee
    'dashboard.title': 'Dashboard',
    'dashboard.subtitle': 'View and manage all cases. Click <strong>Assign to Me</strong> to take ownership of a case.',
    'filter.allCases': 'All Cases',
    'filter.today': 'Today',
    'filter.assignedToMe': 'Assigned to Me',
    'filter.unassigned': 'Unassigned',
    'dashboard.empty.all': 'No cases yet.',
    'dashboard.empty.today': 'No cases created today.',
    'dashboard.empty.mine': 'No cases assigned to you.',
    'dashboard.empty.unassigned': 'No unassigned cases.',
    'dashboard.empty.search': 'No cases match your search.',

    // TABLE HEADERS
    'col.name': 'Name',
    'col.procedure': 'Procedure',
    'col.department': 'Department',
    'col.phone': 'Phone',
    'col.createdBy': 'Created By',
    'col.assignedTo': 'Assigned To',
    'col.status': 'Status',
    'col.source': 'Source',
    'col.cases': 'Cases',
    'col.shareOfTotal': 'Share of total',
    'col.employee': 'Employee',
    'col.casesCreated': 'Cases Created',
    'col.username': 'Username',
    'col.role': 'Role',
    'col.created': 'Created',

    // ADMIN DASHBOARD
    'admin.title': 'Dashboard',
    'admin.subtitle': 'Overview of all cases and referral activity across the team.',
    'admin.totalCases': 'Total Cases',
    'admin.referralSources': 'Referral Sources',
    'admin.employees': 'Employees',
    'admin.allCases': 'All Cases',
    'admin.allEmployees': 'All employees',
    'admin.todayOnly': 'Today only',
    'admin.noData': 'No data yet.',
    'admin.empty.cases': 'No cases match your filters.',
    'admin.empty.noCases': 'No cases in the system yet.',
    'stat.ofTotal': '{n}% of total',
    'stat.ofCreated': '{n}% of created',

    // HOSPITAL MANAGER DASHBOARD
    'hospitalManager.title': 'Hospital Report',
    'hospitalManager.subtitle': 'Ticket volume and success rate by department and doctor.',
    'hospitalManager.departments': 'By Department',
    'hospitalManager.doctors': 'By Doctor',
    'hospitalManager.tickets': 'Tickets',
    'hospitalManager.filterThisMonth': 'This Month',
    'hospitalManager.filterLastMonth': 'Last Month',
    'hospitalManager.filterAllTime': 'All Time',
    'hospitalManager.filterCustom': 'Custom',
    'hospitalManager.reportPeriod': 'Report period',
    'hospitalManager.allTime': 'All time',
    'hospitalManager.export': 'Export Excel',
    'hospitalManager.print': 'Print',

    // FORWARDED BADGES
    'badge.forwarded': 'Forwarded',
    'badge.pending': 'Pending',
    'badge.transferred': 'Transferred',

    // NEW CASE
    'newCase.title': 'New Case',
    'newCase.subtitle': 'Register a new patient case. It starts as <strong>Pending</strong> and is unassigned.',
    'newCase.patientName': 'Patient name',
    'newCase.patientNamePlaceholder': 'Full name',
    'newCase.phone': 'Phone number',
    'newCase.referralSource': 'How did the patient hear about us?',
    'newCase.department': 'Department',
    'newCase.procedure': 'Procedure',
    'newCase.hasDoctor': 'Has a doctor',
    'newCase.doctor': 'Doctor',
    'newCase.description': 'Description',
    'newCase.descriptionPlaceholder': "Describe the patient's inquiry…",
    'newCase.createCase': 'Create case',
    'newCase.creating': 'Creating…',
    'newCase.selectOption': 'Select an option',
    'newCase.selectDepartment': 'Select a department',
    'newCase.selectProcedure': 'Select a procedure',
    'newCase.selectDoctor': 'Select a doctor',
    'newCase.errorReferral': 'Please select how the patient heard about us.',
    'newCase.errorDepartment': 'Please select a department.',
    'newCase.errorProcedure': 'Please select a procedure.',

    // CASES LIST
    'cases.title': 'Cases',
    'cases.subtitle': 'Browse all cases or view only the ones assigned to you. Click a case to view details or follow up.',
    'cases.allCases': 'All Cases',
    'cases.myCases': 'My Cases',
    'cases.empty.all': 'No cases found.',
    'cases.empty.mine': 'You have no assigned cases yet.',
    'cases.empty.search': 'No cases match your search.',

    // FORWARDED TO ME
    'forwardedIn.title': 'Forwarded to Me',
    'forwardedIn.subtitle': "Cases forwarded to you — including those you've accepted and still own.",
    'forwardedIn.empty': 'No cases have been forwarded to you.',

    // FORWARDED BY ME
    'forwardedOut.title': 'Forwarded by Me',
    'forwardedOut.subtitle': 'Cases you forwarded to someone else, so you can track where they are now.',
    'forwardedOut.empty': 'You have not forwarded any cases.',

    // CASE DETAIL
    'case.backToCases': '← Back to cases',
    'case.loading': 'Loading case…',
    'case.noId': 'No case was specified.',
    'case.phone': 'Phone',
    'case.referralSource': 'How they heard about us',
    'case.procedure': 'Procedure',
    'case.department': 'Department',
    'case.doctor': 'Doctor',
    'case.appointment': 'Appointment',
    'case.createdBy': 'Created by',
    'case.assignedTo': 'Assigned to',
    'case.pendingForwardTo': 'Pending forward to',
    'case.created': 'Created',
    'case.description': 'Description',
    'case.signature': 'Signature',
    'case.unassigned': 'Unassigned',
    'case.history': 'History',
    'case.noHistory': 'No history yet.',

    // TIMELINE
    'timeline.created': '{actor} created the case',
    'timeline.forwarded': '{actor} forwarded the case to {target}',
    'timeline.forwardAccepted': '{actor} accepted the forward',
    'timeline.forwardDeclined': '{actor} declined the forward',
    'timeline.claimed': '{actor} claimed this case',
    'timeline.reopened': '{actor} reopened this case',
    'timeline.followUp': '{actor} set status to {status}',
    'timeline.dept': 'Department: {name}',
    'timeline.doctor': 'Doctor: {name}',
    'timeline.date': 'Date: {date}',

    // FOLLOW-UP DIALOG
    'followUp.title': 'Follow-up',
    'followUp.newStatus': 'New status',
    'followUp.date': 'Date',
    'followUp.appointmentDate': 'Appointment date',
    'followUp.department': 'Department',
    'followUp.hasDoctor': 'Has a doctor',
    'followUp.doctor': 'Doctor (optional)',
    'followUp.notes': 'Notes',
    'followUp.notesOptional': 'Notes (optional)',
    'followUp.notesPlaceholder': 'Add notes…',
    'followUp.selectDepartment': 'Select a department',
    'followUp.selectDoctor': 'Select a doctor',
    'followUp.statusSuccess': 'Success',
    'followUp.statusWaiting': 'Waiting (book appointment)',
    'followUp.statusFailed': 'Failed',
    'followUp.statusPending': 'Pending',
    'followUp.clinics': 'Clinics',
    'followUp.signature': 'Signature',
    'followUp.signatureChoose': 'Choose signature image',
    'followUp.signatureRequired': 'A signature image is required.',
    'followUp.errorDate': 'Please choose a date.',
    'followUp.errorDepartment': 'Please choose a department.',
    'followUp.errorNotes': 'Please add notes for this update.',

    // FORWARD DIALOG
    'forward.title': 'Forward Case',
    'forward.forwardTo': 'Forward to',
    'forward.note': 'Note (optional)',
    'forward.selectColleague': 'Select a colleague',
    'forward.notePlaceholder': 'Add a note for the recipient…',
    'forward.errorColleague': 'Please select a colleague to forward to.',

    // MANAGE LISTS
    'manageLists.title': 'Manage Lists',
    'manageLists.subtitle': 'Lookup values used across the app.',
    'manageLists.departments': 'Departments',
    'manageLists.referralSources': 'Referral Sources',
    'manageLists.doctors': 'Doctors',
    'manageLists.procedures': 'Procedures',
    'manageLists.searchPlaceholder': 'Search…',
    'manageLists.addBtn': '+ Add',
    'manageLists.colName': 'Name',
    'manageLists.colStatus': 'Status',
    'manageLists.showing': 'Showing {n} of {total}',
    'manageLists.empty.departments': 'No departments yet.',
    'manageLists.empty.referralSources': 'No referral sources yet.',
    'manageLists.empty.doctors': 'No doctors yet.',
    'manageLists.empty.procedures': 'No procedures yet.',
    'manageLists.empty.search': 'No matches for your search.',
    'manageLists.desc.departments': 'Used when booking an appointment in a Waiting follow-up.',
    'manageLists.desc.referralSources': 'Shown as a dropdown option when creating a new case.',
    'manageLists.desc.doctors': 'Assigned during a Waiting follow-up.',
    'manageLists.desc.procedures': 'The medical procedure a patient case is associated with.',

    // ADD/EDIT LIST ITEM DIALOG
    'listItem.addDept': 'Add Department',
    'listItem.editDept': 'Edit Department',
    'listItem.addRef': 'Add Referral Source',
    'listItem.editRef': 'Edit Referral Source',
    'listItem.addDoctor': 'Add Doctor',
    'listItem.editDoctor': 'Edit Doctor',
    'listItem.addProc': 'Add Procedure',
    'listItem.editProc': 'Edit Procedure',
    'listItem.name': 'Name',

    // CONFIRM DIALOG — manage lists
    'confirm.title': 'Confirm',
    'confirm.enable': 'Re-enable "{name}"? It will be selectable again.',
    'confirm.disable': 'Disable "{name}"? It will no longer be selectable.',

    // USER MANAGEMENT
    'users.title': 'User Management',
    'users.subtitle': 'Create, edit, and manage staff accounts.',
    'users.addUser': '+ Add User',
    'users.loading': 'Loading users…',
    'users.empty': 'No users yet.',
    'users.colUsername': 'Username',
    'users.colRole': 'Role',
    'users.colStatus': 'Status',
    'users.colCreated': 'Created',
    'users.selfDisableTooltip': 'You cannot disable your own account',

    // USER FORM DIALOG
    'userForm.addTitle': 'Add User',
    'userForm.editTitle': 'Edit User',
    'userForm.username': 'Username',
    'userForm.usernamePlaceholder': 'e.g. jdoe',
    'userForm.password': 'Password',
    'userForm.passwordPlaceholder': 'At least 6 characters',
    'userForm.role': 'Role',
    'userForm.notifyNewCase': 'Receives new case alerts',
    'userForm.errorPassword': 'Password must be at least 6 characters.',

    // RESET PASSWORD DIALOG
    'resetPassword.title': 'Reset Password',
    'resetPassword.subtitle': 'Set a new password for <strong>{username}</strong>.',
    'resetPassword.newPassword': 'New password',
    'resetPassword.placeholder': 'At least 6 characters',
    'resetPassword.errorPassword': 'Password must be at least 6 characters.',

    // CONFIRM USER STATUS DIALOG
    'confirmUser.title': 'Confirm',
    'confirmUser.enableMsg': "Re-enable {username}'s account? They will be able to sign in again.",
    'confirmUser.disableMsg': "Disable {username}'s account? They will no longer be able to sign in.",
  },

  ar: {
    // NAV
    'nav.dashboard': 'لوحة التحكم',
    'nav.newCase': 'حالة جديدة',
    'nav.cases': 'الحالات',
    'nav.forwardedToMe': 'المُحوَّل إليّ',
    'nav.forwardedByMe': 'المُحوَّل منّي',
    'nav.manageLists': 'إدارة القوائم',
    'nav.userManagement': 'إدارة المستخدمين',
    'nav.hospitalReport': 'تقرير المستشفى',
    'nav.contact': 'تواصل',
    'nav.systemParams': 'معايير النظام',

    // WEBSITE / MULTI-SITE
    'website.pickTitle': 'اختر مساحة العمل',
    'website.pickSubtitle': 'اختر الموقع الذي تريد العمل فيه.',
    'website.current': 'الموقع الحالي: {name}',
    'login.noWebsiteAccess': 'ليس لحسابك صلاحية الوصول إلى أي موقع. يرجى التواصل مع المسؤول.',
    'contact.title': 'تواصل',
    'contact.comingSoon': 'هذا الموقع قيد الإنشاء.',
    'userForm.websites': 'صلاحيات المواقع',
    'userForm.websitesAdminNote': 'يمكن للمسؤول الوصول إلى جميع المواقع.',
    'userForm.websitesNone': 'لا توجد مواقع متاحة.',
    'systemParams.title': 'معايير النظام',
    'systemParams.subtitle': 'إعدادات خاصة بالموقع لـ',
    'systemParams.add': '+ إضافة معيار',
    'systemParams.loading': 'جارٍ تحميل المعايير…',
    'systemParams.key': 'المفتاح',
    'systemParams.value': 'القيمة',
    'systemParams.keyPlaceholder': 'مثال: supportPhone',
    'systemParams.valuePlaceholder': 'القيمة',
    'systemParams.empty': 'لا توجد معايير بعد. أضف واحدًا للبدء.',
    'systemParams.saved': 'تم الحفظ.',
    'systemParams.duplicateKey': 'لا يُسمح بمفاتيح مكررة.',
    'systemParams.loadError': 'تعذّر تحميل المعايير.',
    'systemParams.saveError': 'تعذّر حفظ المعايير.',
    'action.delete': 'حذف',

    // TOPBAR
    'topbar.hi': 'مرحباً، {name}',
    'topbar.logout': 'تسجيل الخروج',
    'topbar.openMenu': 'فتح القائمة',
    'topbar.closeMenu': 'إغلاق القائمة',
    'topbar.notifications': 'الإشعارات',

    // LOGIN
    'login.title': 'مرحباً بك',
    'login.subtitle': 'سجّل الدخول للمتابعة إلى لوحة التحكم',
    'login.username': 'اسم المستخدم',
    'login.usernamePlaceholder': 'أدخل اسم المستخدم',
    'login.password': 'كلمة المرور',
    'login.passwordPlaceholder': 'أدخل كلمة المرور',
    'login.showPassword': 'إظهار كلمة المرور',
    'login.hidePassword': 'إخفاء كلمة المرور',
    'login.signIn': 'تسجيل الدخول',
    'login.signingIn': 'جارٍ التسجيل...',
    'login.footer': 'تحتاج إلى حساب؟ تواصل مع مسؤول النظام.',
    'login.brandTitle': 'نظام إدارة الموارد السريرية',
    'login.brandSubtitle': 'وصول آمن لموظفي المستشفى. سجّل دخولك بالبيانات التي زوّدك بها المسؤول.',
    'login.feature1': 'سجلات المرضى والحالات، دائماً متزامنة',
    'login.feature2': 'مراقبة فورية لكل قسم',
    'login.feature3': 'صلاحيات حسب الدور، محمية من البداية للنهاية',
    'login.errorEmpty': 'يرجى إدخال اسم المستخدم وكلمة المرور.',
    'login.errorGeneric': 'حدث خطأ ما. يرجى المحاولة مجدداً.',

    // STATUS
    'status.pending': 'معلّق',
    'status.waiting': 'انتظار',
    'status.success': 'نجاح',
    'status.failed': 'فشل',

    // ACTIVE STATE
    'state.active': 'نشط',
    'state.disabled': 'معطّل',

    // ROLES
    'role.employee': 'موظف',
    'role.manager': 'مدير',
    'role.admin': 'مدير النظام',
    'role.hospitalManager': 'مدير المستشفى',

    // COMMON ACTIONS
    'action.view': 'عرض',
    'action.edit': 'تعديل',
    'action.save': 'حفظ',
    'action.saving': 'جارٍ الحفظ...',
    'action.cancel': 'إلغاء',
    'action.confirm': 'تأكيد',
    'action.add': 'إضافة',
    'action.enable': 'تفعيل',
    'action.disable': 'تعطيل',
    'action.close': 'إغلاق',
    'action.assignToMe': 'تعيين لي',
    'action.assigning': 'جارٍ التعيين…',
    'action.followUp': 'متابعة',
    'action.forward': 'تحويل',
    'action.accept': 'قبول',
    'action.decline': 'رفض',
    'action.reopen': 'إعادة فتح',
    'action.markAllRead': 'تحديد الكل كمقروء',
    'action.resetPassword': 'إعادة تعيين كلمة المرور',
    'action.addUser': '+ إضافة مستخدم',

    // LOADING / EMPTY
    'loading.cases': 'جارٍ تحميل الحالات…',
    'loading.users': 'جارٍ تحميل المستخدمين…',
    'loading.case': 'جارٍ تحميل الحالة…',
    'loading.stats': 'جارٍ تحميل الإحصائيات…',
    'loading.generic': 'جارٍ التحميل…',

    // SEARCH
    'search.placeholder': 'ابحث بالاسم أو الهاتف…',
    'search.noMatch': 'لا توجد حالات تطابق بحثك.',

    // NOTIFICATIONS
    'notifications.title': 'الإشعارات',
    'notifications.markAllRead': 'تحديد الكل كمقروء',
    'notifications.loading': 'جارٍ التحميل…',
    'notifications.empty': 'لا توجد إشعارات جديدة.',
    'notifications.delete': 'حذف الإشعار',

    // DASHBOARD — employee
    'dashboard.title': 'لوحة التحكم',
    'dashboard.subtitle': 'استعرض وأدِر جميع الحالات. اضغط على <strong>تعيين لي</strong> للاستلام.',
    'filter.allCases': 'جميع الحالات',
    'filter.today': 'اليوم',
    'filter.assignedToMe': 'مُعيَّنة لي',
    'filter.unassigned': 'غير مُعيَّنة',
    'dashboard.empty.all': 'لا توجد حالات بعد.',
    'dashboard.empty.today': 'لا توجد حالات اليوم.',
    'dashboard.empty.mine': 'لا توجد حالات مُعيَّنة لك.',
    'dashboard.empty.unassigned': 'لا توجد حالات غير مُعيَّنة.',
    'dashboard.empty.search': 'لا توجد حالات تطابق بحثك.',

    // TABLE HEADERS
    'col.name': 'الاسم',
    'col.procedure': 'الإجراء',
    'col.department': 'القسم',
    'col.phone': 'الهاتف',
    'col.createdBy': 'أُنشئ بواسطة',
    'col.assignedTo': 'مُعيَّن لـ',
    'col.status': 'الحالة',
    'col.source': 'المصدر',
    'col.cases': 'الحالات',
    'col.shareOfTotal': 'نسبة من الإجمالي',
    'col.employee': 'الموظف',
    'col.casesCreated': 'الحالات المُنشأة',
    'col.username': 'اسم المستخدم',
    'col.role': 'الدور',
    'col.created': 'تاريخ الإنشاء',

    // ADMIN DASHBOARD
    'admin.title': 'لوحة التحكم',
    'admin.subtitle': 'نظرة عامة على جميع الحالات ونشاط الإحالة عبر الفريق.',
    'admin.totalCases': 'إجمالي الحالات',
    'admin.referralSources': 'مصادر الإحالة',
    'admin.employees': 'الموظفون',
    'admin.allCases': 'جميع الحالات',
    'admin.allEmployees': 'جميع الموظفين',
    'admin.todayOnly': 'اليوم فقط',
    'admin.noData': 'لا توجد بيانات بعد.',
    'admin.empty.cases': 'لا توجد حالات تطابق الفلاتر.',
    'admin.empty.noCases': 'لا توجد حالات في النظام بعد.',
    'stat.ofTotal': '{n}% من الإجمالي',
    'stat.ofCreated': '{n}% من المُنشأة',

    // HOSPITAL MANAGER DASHBOARD
    'hospitalManager.title': 'تقرير المستشفى',
    'hospitalManager.subtitle': 'عدد الحالات ونسبة النجاح لكل قسم وطبيب.',
    'hospitalManager.departments': 'حسب القسم',
    'hospitalManager.doctors': 'حسب الطبيب',
    'hospitalManager.tickets': 'الحالات',
    'hospitalManager.filterThisMonth': 'هذا الشهر',
    'hospitalManager.filterLastMonth': 'الشهر الماضي',
    'hospitalManager.filterAllTime': 'كل الوقت',
    'hospitalManager.filterCustom': 'مخصص',
    'hospitalManager.reportPeriod': 'فترة التقرير',
    'hospitalManager.allTime': 'كل الوقت',
    'hospitalManager.export': 'تصدير إكسل',
    'hospitalManager.print': 'طباعة',

    // FORWARDED BADGES
    'badge.forwarded': 'مُحوَّل',
    'badge.pending': 'معلّق',
    'badge.transferred': 'مُنقل',

    // NEW CASE
    'newCase.title': 'حالة جديدة',
    'newCase.subtitle': 'سجّل حالة مريض جديدة. تبدأ بحالة <strong>معلّق</strong> وغير مُعيَّنة.',
    'newCase.patientName': 'اسم المريض',
    'newCase.patientNamePlaceholder': 'الاسم الكامل',
    'newCase.phone': 'رقم الهاتف',
    'newCase.referralSource': 'كيف سمع المريض عنّا؟',
    'newCase.department': 'القسم',
    'newCase.procedure': 'الإجراء',
    'newCase.hasDoctor': 'لديه طبيب',
    'newCase.doctor': 'الطبيب',
    'newCase.description': 'الوصف',
    'newCase.descriptionPlaceholder': 'اكتب ملخصاً عن استفسار المريض…',
    'newCase.createCase': 'إنشاء حالة',
    'newCase.creating': 'جارٍ الإنشاء…',
    'newCase.selectOption': 'اختر خياراً',
    'newCase.selectDepartment': 'اختر قسماً',
    'newCase.selectProcedure': 'اختر إجراءً',
    'newCase.selectDoctor': 'اختر طبيباً',
    'newCase.errorReferral': 'يرجى تحديد كيف سمع المريض عنّا.',
    'newCase.errorDepartment': 'يرجى تحديد القسم.',
    'newCase.errorProcedure': 'يرجى تحديد الإجراء.',

    // CASES LIST
    'cases.title': 'الحالات',
    'cases.subtitle': 'استعرض جميع الحالات أو الحالات المُعيَّنة لك. اضغط على حالة للتفاصيل.',
    'cases.allCases': 'جميع الحالات',
    'cases.myCases': 'حالاتي',
    'cases.empty.all': 'لا توجد حالات.',
    'cases.empty.mine': 'لا توجد حالات مُعيَّنة لك بعد.',
    'cases.empty.search': 'لا توجد حالات تطابق بحثك.',

    // FORWARDED TO ME
    'forwardedIn.title': 'المُحوَّل إليّ',
    'forwardedIn.subtitle': 'الحالات المُحوَّلة إليك — بما فيها التي قبلتها وما زلت تمتلكها.',
    'forwardedIn.empty': 'لم يتم تحويل أي حالات إليك.',

    // FORWARDED BY ME
    'forwardedOut.title': 'المُحوَّل منّي',
    'forwardedOut.subtitle': 'الحالات التي حوّلتها لزميل آخر لمتابعة وضعها.',
    'forwardedOut.empty': 'لم تقم بتحويل أي حالات.',

    // CASE DETAIL
    'case.backToCases': '← العودة إلى الحالات',
    'case.loading': 'جارٍ تحميل الحالة…',
    'case.noId': 'لم يتم تحديد حالة.',
    'case.phone': 'الهاتف',
    'case.referralSource': 'كيف سمعوا عنّا',
    'case.procedure': 'الإجراء',
    'case.department': 'القسم',
    'case.doctor': 'الطبيب',
    'case.appointment': 'الموعد',
    'case.createdBy': 'أُنشئ بواسطة',
    'case.assignedTo': 'مُعيَّن لـ',
    'case.pendingForwardTo': 'في انتظار تحويل إلى',
    'case.created': 'تاريخ الإنشاء',
    'case.description': 'الوصف',
    'case.signature': 'التوقيع',
    'case.unassigned': 'غير مُعيَّن',
    'case.history': 'السجل',
    'case.noHistory': 'لا يوجد سجل بعد.',

    // TIMELINE
    'timeline.created': 'أنشأ {actor} الحالة',
    'timeline.forwarded': 'حوّل {actor} الحالة إلى {target}',
    'timeline.forwardAccepted': 'قبل {actor} التحويل',
    'timeline.forwardDeclined': 'رفض {actor} التحويل',
    'timeline.claimed': 'استلم {actor} هذه الحالة',
    'timeline.reopened': 'أعاد {actor} فتح هذه الحالة',
    'timeline.followUp': 'غيّر {actor} الحالة إلى {status}',
    'timeline.dept': 'القسم: {name}',
    'timeline.doctor': 'الطبيب: {name}',
    'timeline.date': 'التاريخ: {date}',

    // FOLLOW-UP DIALOG
    'followUp.title': 'متابعة',
    'followUp.newStatus': 'الحالة الجديدة',
    'followUp.date': 'التاريخ',
    'followUp.appointmentDate': 'تاريخ الموعد',
    'followUp.department': 'القسم',
    'followUp.hasDoctor': 'لديه طبيب',
    'followUp.doctor': 'الطبيب (اختياري)',
    'followUp.notes': 'الملاحظات',
    'followUp.notesOptional': 'الملاحظات (اختياري)',
    'followUp.notesPlaceholder': 'أضف ملاحظات…',
    'followUp.selectDepartment': 'اختر قسماً',
    'followUp.selectDoctor': 'اختر طبيباً',
    'followUp.statusSuccess': 'نجاح',
    'followUp.statusWaiting': 'انتظار (حجز موعد)',
    'followUp.statusFailed': 'فشل',
    'followUp.statusPending': 'معلّق',
    'followUp.clinics': 'عيادات',
    'followUp.signature': 'التوقيع',
    'followUp.signatureChoose': 'اختر صورة التوقيع',
    'followUp.signatureRequired': 'صورة التوقيع مطلوبة.',
    'followUp.errorDate': 'يرجى اختيار تاريخ.',
    'followUp.errorDepartment': 'يرجى اختيار القسم.',
    'followUp.errorNotes': 'يرجى إضافة ملاحظات لهذا التحديث.',

    // FORWARD DIALOG
    'forward.title': 'تحويل الحالة',
    'forward.forwardTo': 'تحويل إلى',
    'forward.note': 'ملاحظة (اختياري)',
    'forward.selectColleague': 'اختر زميلاً',
    'forward.notePlaceholder': 'أضف ملاحظة للمستلم…',
    'forward.errorColleague': 'يرجى تحديد زميل للتحويل إليه.',

    // MANAGE LISTS
    'manageLists.title': 'إدارة القوائم',
    'manageLists.subtitle': 'قيم البحث المُستخدمة في التطبيق.',
    'manageLists.departments': 'الأقسام',
    'manageLists.referralSources': 'مصادر الإحالة',
    'manageLists.doctors': 'الأطباء',
    'manageLists.procedures': 'الإجراءات',
    'manageLists.searchPlaceholder': 'بحث…',
    'manageLists.addBtn': '+ إضافة',
    'manageLists.colName': 'الاسم',
    'manageLists.colStatus': 'الحالة',
    'manageLists.showing': 'عرض {n} من {total}',
    'manageLists.empty.departments': 'لا توجد أقسام بعد.',
    'manageLists.empty.referralSources': 'لا توجد مصادر إحالة بعد.',
    'manageLists.empty.doctors': 'لا يوجد أطباء بعد.',
    'manageLists.empty.procedures': 'لا توجد إجراءات بعد.',
    'manageLists.empty.search': 'لا توجد نتائج لبحثك.',
    'manageLists.desc.departments': 'يُستخدم عند حجز موعد في متابعة الانتظار.',
    'manageLists.desc.referralSources': 'يظهر كخيار في القائمة عند إنشاء حالة جديدة.',
    'manageLists.desc.doctors': 'يُعيَّن خلال متابعة الانتظار.',
    'manageLists.desc.procedures': 'الإجراء الطبي المرتبط بحالة المريض.',

    // ADD/EDIT LIST ITEM DIALOG
    'listItem.addDept': 'إضافة قسم',
    'listItem.editDept': 'تعديل قسم',
    'listItem.addRef': 'إضافة مصدر إحالة',
    'listItem.editRef': 'تعديل مصدر إحالة',
    'listItem.addDoctor': 'إضافة طبيب',
    'listItem.editDoctor': 'تعديل طبيب',
    'listItem.addProc': 'إضافة إجراء',
    'listItem.editProc': 'تعديل إجراء',
    'listItem.name': 'الاسم',

    // CONFIRM DIALOG — manage lists
    'confirm.title': 'تأكيد',
    'confirm.enable': 'إعادة تفعيل "{name}"؟ ستصبح قابلة للاختيار مجدداً.',
    'confirm.disable': 'تعطيل "{name}"؟ لن تكون قابلة للاختيار.',

    // USER MANAGEMENT
    'users.title': 'إدارة المستخدمين',
    'users.subtitle': 'إنشاء وتعديل وإدارة حسابات الموظفين.',
    'users.addUser': '+ إضافة مستخدم',
    'users.loading': 'جارٍ تحميل المستخدمين…',
    'users.empty': 'لا يوجد مستخدمون بعد.',
    'users.colUsername': 'اسم المستخدم',
    'users.colRole': 'الدور',
    'users.colStatus': 'الحالة',
    'users.colCreated': 'تاريخ الإنشاء',
    'users.selfDisableTooltip': 'لا يمكنك تعطيل حسابك الخاص',

    // USER FORM DIALOG
    'userForm.addTitle': 'إضافة مستخدم',
    'userForm.editTitle': 'تعديل مستخدم',
    'userForm.username': 'اسم المستخدم',
    'userForm.usernamePlaceholder': 'مثال: jdoe',
    'userForm.password': 'كلمة المرور',
    'userForm.passwordPlaceholder': '6 أحرف على الأقل',
    'userForm.role': 'الدور',
    'userForm.notifyNewCase': 'يستقبل تنبيهات الحالات الجديدة',
    'userForm.errorPassword': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',

    // RESET PASSWORD DIALOG
    'resetPassword.title': 'إعادة تعيين كلمة المرور',
    'resetPassword.subtitle': 'تعيين كلمة مرور جديدة لـ <strong>{username}</strong>.',
    'resetPassword.newPassword': 'كلمة المرور الجديدة',
    'resetPassword.placeholder': '6 أحرف على الأقل',
    'resetPassword.errorPassword': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',

    // CONFIRM USER STATUS DIALOG
    'confirmUser.title': 'تأكيد',
    'confirmUser.enableMsg': 'إعادة تفعيل حساب {username}؟ سيتمكن من تسجيل الدخول مجدداً.',
    'confirmUser.disableMsg': 'تعطيل حساب {username}؟ لن يتمكن من تسجيل الدخول.',
  }
};

function getLang() {
  return localStorage.getItem('lang') || 'en';
}

function setLang(lang) {
  localStorage.setItem('lang', lang);
  location.reload();
}

// Interpolates {key} placeholders in a translated string.
function t(key, vars = {}) {
  const lang = getLang();
  const map = TRANSLATIONS[lang] || TRANSLATIONS.en;
  let str = map[key] ?? TRANSLATIONS.en[key] ?? key;
  for (const [k, v] of Object.entries(vars)) {
    str = str.replaceAll(`{${k}}`, v);
  }
  return str;
}

// Applies translations to all [data-i18n], [data-i18n-placeholder], [data-i18n-aria] elements.
function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    el.textContent = t(el.dataset.i18n);
  });
  document.querySelectorAll('[data-i18n-html]').forEach((el) => {
    el.innerHTML = t(el.dataset.i18nHtml);
  });
  document.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
    el.placeholder = t(el.dataset.i18nPlaceholder);
  });
  document.querySelectorAll('[data-i18n-aria]').forEach((el) => {
    el.setAttribute('aria-label', t(el.dataset.i18nAria));
  });
  document.querySelectorAll('[data-i18n-title]').forEach((el) => {
    el.setAttribute('title', t(el.dataset.i18nTitle));
  });
  const btn = document.getElementById('lang-toggle');
  if (btn) btn.textContent = getLang() === 'ar' ? 'English' : 'العربية';
}

document.addEventListener('DOMContentLoaded', () => {
  applyTranslations();
  const btn = document.getElementById('lang-toggle');
  if (btn) {
    btn.addEventListener('click', () => setLang(getLang() === 'ar' ? 'en' : 'ar'));
  }
});
