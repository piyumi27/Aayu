# 📱 Aayu (ආයු) - Technical User Guide

> **Comprehensive Technical Documentation for Aayu Application**  
> Complete flow diagrams, activity patterns, and system architecture

## Table of Contents

1. [Welcome to Aayu](#welcome-to-aayu)
2. [Getting Started](#getting-started)
3. [Initial Setup](#initial-setup)
4. [Main Features](#main-features)
5. [Navigation Guide](#navigation-guide)
6. [Feature Details](#feature-details)
7. [Advanced Features](#advanced-features)
8. [User Flow Diagrams](#user-flow-diagrams)
9. [Activity Diagrams](#activity-diagrams)
10. [System Architecture](#system-architecture)

---

## 🎯 Welcome to Aayu

### What is Aayu?

**Aayu (ආයු)** is a specialized child nutrition and growth tracking application designed specifically for Sri Lankan families. The app helps parents monitor their children's development from birth to 5 years, providing culturally relevant guidance and WHO-standard growth tracking.

### Key Benefits

- **📊 Growth Tracking**: Monitor weight, height, and BMI against WHO standards
- **💉 Vaccination Management**: Never miss an immunization appointment
- **🥗 Nutrition Guidance**: Get age-appropriate nutrition recommendations
- **🌐 Multilingual Support**: Available in English, Sinhala (සිංහල), and Tamil (தமிழ்)
- **📱 Offline-First**: Works without internet, syncs when connected
- **🔒 Privacy-Focused**: Your data stays secure and private

### Who Should Use Aayu?

- Parents with children aged 0-5 years
- Healthcare providers monitoring child growth
- Caregivers tracking multiple children
- Families seeking nutrition guidance

---

## 🚀 Getting Started

### System Requirements

#### Android
- Android 5.0 (API level 21) or higher
- At least 100MB free storage
- Camera access for profile pictures (optional)

#### iOS
- iOS 12.0 or later
- iPhone, iPad, or iPod touch
- At least 100MB free storage

### Installation

1. **Download the App**
   - Android: Visit Google Play Store and search "Aayu Sri Lanka"
   - iOS: Visit Apple App Store and search "Aayu"
   
2. **Install & Open**
   - Tap "Install" and wait for download
   - Open the app from your home screen

3. **Grant Permissions** (Optional)
   - Camera: For taking profile pictures
   - Storage: For saving profile images
   - Notifications: For vaccination reminders

---

## 🎬 Initial Setup

### 1. Language Selection

When you first open Aayu, you'll see the **Language Selection Screen**:

- **English** - International language
- **සිංහල** - Sinhala interface
- **தமிழ்** - Tamil interface

> 💡 **Tip**: You can change the language anytime from Settings

### 2. Onboarding Tour

The app will guide you through its main features:

1. **Welcome Screen** - Introduction to Aayu
2. **Growth Tracking** - Learn about monitoring development
3. **Vaccination Calendar** - Understanding immunization tracking
4. **Nutrition Guide** - Discover meal planning features

> You can skip the tour if you're familiar with the app

### 3. Account Registration

#### Creating Your Account

**Step 1: Choose Registration Method**
- Email registration
- Phone number registration

**Step 2: Enter Your Details**
- Full Name (required)
- Email Address (if email method)
- Phone Number (required for phone method)
- Password (minimum 8 characters)

**Step 3: Verify Your Account**
- For email: Click verification link sent to your email
- For phone: Enter 6-digit OTP sent via SMS

**Step 4: Complete Profile**
- Add profile picture (optional)
- Set notification preferences
- Configure units (Metric/Imperial)

#### Login for Existing Users

1. Tap "Already have an account? Login"
2. Enter your email/phone and password
3. Tap "Login"
4. Use "Forgot Password?" if needed

### 4. Adding Your First Child

After registration, you'll be prompted to add your child:

**Required Information:**
- Child's name
- Date of birth
- Gender (Male/Female)

**Optional Information:**
- Birth weight (kg/lbs)
- Birth height (cm/inches)
- Profile picture
- Medical notes

> 📝 **Note**: You can add multiple children and switch between profiles

---

## 🏠 Main Features

### Dashboard Overview

The home screen provides a comprehensive view of your child's health:

#### Child Selector
- **Profile Pills**: Quick switch between multiple children
- **Add Child Button**: Register additional children
- Shows current selected child's name and age

#### Child Information Card
Displays:
- Child's profile picture or initial
- Name and exact age (years, months, days)
- Current weight, height, and BMI
- Nutritional status indicator

#### Quick Actions Grid

For children **under 6 months**:
1. **Growth Countdown** (First Priority)
   - Track daily progress to 6-month milestone
   - View days completed and remaining
   - Access tips for infant care

2. **Add Measurement**
   - Record weight and height
   - Auto-calculate BMI
   - Add measurement notes

3. **Growth Charts**
   - View WHO standard curves
   - Track progress over time
   - Compare with percentiles

4. **Vaccines**
   - Check upcoming vaccines
   - Mark completed immunizations
   - Set reminders

For children **over 6 months**:
- Standard grid without Growth Countdown
- Focus shifts to regular tracking

#### Recent Activity Timeline
- Shows last 5 actions
- Includes timestamps
- Quick access to details

---

## 🧭 Navigation Guide

### Bottom Navigation Bar

Aayu uses a 5-tab navigation system:

#### 1. **Home** 🏠
- Dashboard overview
- Quick actions
- Child selector
- Recent activities

#### 2. **Growth** 📈
- Growth charts (Weight, Height, BMI)
- Percentile tracking
- Export data options
- Historical trends

#### 3. **Medicine** 💊
- Vaccination calendar
- Completed vaccines
- Upcoming schedules
- Health records

#### 4. **Learn** 📚
- Nutrition articles
- Meal planning guides
- Development milestones
- Parenting tips

#### 5. **Profile** 👤
- Parent profile management
- App settings
- Help & support
- Account options

---

## 📋 Feature Details

### 1. Growth Tracking

#### Adding Measurements

**Steps:**
1. Tap "Add Measurement" from dashboard
2. Enter current date (defaults to today)
3. Input weight in kg or lbs
4. Input height in cm or inches
5. BMI calculates automatically
6. Add optional notes
7. Tap "Save Measurement"

#### Understanding Growth Charts

**Chart Types:**
- **Weight-for-Age**: Track weight progression
- **Height-for-Age**: Monitor height development
- **BMI-for-Age**: Assess nutritional status

**Percentile Lines:**
- 97th percentile (top line)
- 85th percentile
- 50th percentile (median)
- 15th percentile
- 3rd percentile (bottom line)

**Status Indicators:**
- 🟢 **Green Zone**: Normal range (15th-85th percentile)
- 🟡 **Yellow Zone**: Monitor closely (3rd-15th or 85th-97th)
- 🔴 **Red Zone**: Consult healthcare provider (<3rd or >97th)

#### Exporting Data

1. Open Growth Charts
2. Tap menu (⋮) button
3. Select "Export Data"
4. Choose format:
   - PDF Report
   - CSV Spreadsheet
   - Image Charts
5. Share via email or save

### 2. Vaccination Management

#### Vaccination Calendar View

**Calendar Features:**
- Monthly grid view
- Color-coded vaccine types
- Tap date for details
- Swipe to change months

**Vaccine Status:**
- ✅ **Completed**: Green checkmark
- 📅 **Scheduled**: Blue calendar icon
- ⚠️ **Overdue**: Red warning
- 🔔 **Upcoming**: Yellow bell (within 7 days)

#### Managing Vaccines

**Mark as Complete:**
1. Find vaccine in list
2. Tap checkbox or vaccine card
3. Enter administration date
4. Add notes (optional)
5. Save record

**Set Reminders:**
1. Tap on upcoming vaccine
2. Select "Set Reminder"
3. Choose notification time:
   - 1 week before
   - 3 days before
   - 1 day before
   - On the day
4. Enable notifications

#### Sri Lankan Immunization Schedule

**Birth:**
- BCG (Tuberculosis)
- Hepatitis B - First dose

**2 Months:**
- Pentavalent - First dose
- OPV - First dose
- Rotavirus - First dose
- PCV - First dose

**4 Months:**
- Pentavalent - Second dose
- OPV - Second dose
- Rotavirus - Second dose
- PCV - Second dose

**6 Months:**
- Pentavalent - Third dose
- OPV - Third dose
- PCV - Third dose
- Vitamin A - First dose

**9 Months:**
- MMR - First dose
- Japanese Encephalitis

**12 Months:**
- Vitamin A - Second dose

**18 Months:**
- DPT booster
- OPV booster
- MMR - Second dose

**3 Years:**
- Japanese Encephalitis booster

**5 Years:**
- DT
- OPV booster

### 3. Nutrition Guidance

#### Age-Based Recommendations

**0-6 Months:**
- Exclusive breastfeeding
- No water needed
- Vitamin D supplementation
- Iron supplements (if prescribed)

**6-12 Months:**
- Introduction to solid foods
- Continue breastfeeding
- Iron-rich foods priority
- Texture progression guide

**1-2 Years:**
- Family food introduction
- Portion size guide
- Snack recommendations
- Milk transition advice

**2-5 Years:**
- Balanced diet planning
- Dealing with picky eating
- Healthy snack ideas
- Hydration guidelines

#### Meal Planning Features

**Create Meal Plan:**
1. Go to Learn → Nutrition Guide
2. Select child's age group
3. Choose meal type:
   - Breakfast
   - Morning snack
   - Lunch
   - Evening snack
   - Dinner
4. Browse suggested recipes
5. Save to meal planner

**Recipe Categories:**
- Traditional Sri Lankan
- Quick & Easy
- Nutritious snacks
- Special dietary needs

### 4. 6-Month Growth Countdown

**For infants under 6 months only**

#### Daily Progress Tracking

**Main Display:**
- Large circular progress ring
- Days completed (center number)
- Days remaining
- Progress percentage
- Color gradient (green to blue)

#### Milestone Markers

- **Day 30**: First month celebration
- **Day 60**: Two months milestone
- **Day 90**: Quarter-year mark
- **Day 120**: Four months
- **Day 150**: Five months
- **Day 180**: Six months complete!

#### Daily Tips

Rotating tips include:
- Breastfeeding guidance
- Sleep recommendations
- Development activities
- Safety reminders
- Parent self-care

### 5. Child Profile Management

#### Editing Child Information

1. Go to Profile tab
2. Select child from dropdown
3. Tap "Edit Profile"
4. Update information:
   - Name
   - Birth date
   - Gender
   - Profile picture
   - Medical notes
5. Save changes

#### Adding Profile Pictures

**Taking a New Photo:**
1. Tap profile picture area
2. Select "Camera"
3. Take photo
4. Crop/adjust if needed
5. Confirm selection

**Choosing from Gallery:**
1. Tap profile picture area
2. Select "Gallery"
3. Choose photo
4. Crop/adjust
5. Confirm selection

#### Managing Multiple Children

**Add New Child:**
1. Dashboard → "Add Child" button
2. Enter child details
3. Save profile

**Switch Between Children:**
- Tap child name pills at top
- Selected child highlighted in blue
- All data updates for selected child

**Remove Child:**
1. Edit child profile
2. Scroll to bottom
3. Tap "Remove Child"
4. Confirm deletion

---

## 🚀 Advanced Features

### 1. Progress Tracking & Analytics

**Access:** Home → Progress Tracking

**Features:**
- Weekly/Monthly/Quarterly views
- Growth velocity calculations
- Milestone achievements
- Comparative analytics
- Export detailed reports

**Understanding Metrics:**
- **Growth Velocity**: Rate of weight/height gain
- **Z-Score**: Standard deviations from median
- **Percentile Rank**: Position relative to peers
- **BMI Trend**: Nutritional status over time

### 2. Achievement System

**Access:** Home → Achievements

**Achievement Categories:**
- **Milestones**: Age-based achievements
- **Daily**: Consistent tracking rewards
- **Weekly**: Regular engagement
- **Special**: Unique accomplishments

**Rarity Levels:**
- 🥉 Bronze: Common achievements
- 🥈 Silver: Moderate difficulty
- 🥇 Gold: Challenging goals
- 💎 Platinum: Rare accomplishments
- 💠 Diamond: Exceptional milestones

**Points & Levels:**
- Earn XP for each achievement
- Level up with accumulated points
- Unlock new features at higher levels

### 3. Data Synchronization

**Offline Mode:**
- All features work without internet
- Data stored locally on device
- Automatic queue for sync

**Cloud Sync:**
- Enable in Settings → Data & Privacy
- Requires verified account
- Syncs when connected to internet
- Conflict resolution (last-write-wins)

**Sync Indicators:**
- ✅ Synced: All data up-to-date
- 🔄 Syncing: Upload in progress
- ⏸️ Pending: Waiting for connection
- ❌ Error: Sync failed (tap for details)

### 4. Notifications & Reminders

**Types of Notifications:**
- Vaccination reminders
- Measurement prompts
- Milestone alerts
- Achievement unlocks
- App updates

**Customization:**
1. Settings → Notifications
2. Toggle categories on/off
3. Set quiet hours
4. Choose notification sound
5. Configure frequency

### 5. Data Export & Reports

**Generate Reports:**
1. Profile → Reports
2. Select report type:
   - Growth Summary
   - Vaccination Record
   - Nutrition Analysis
   - Complete Health Report
3. Choose date range
4. Select format (PDF/Excel)
5. Share or save

**Report Contents:**
- Child information
- Growth charts
- Measurement history
- Vaccination status
- Nutritional assessments
- Doctor's notes section

### 6. Settings & Customization

#### Account Settings

**Profile Management:**
- Edit name and contact
- Change profile picture
- Update password
- Manage email/phone
- Delete account option

**Privacy Settings:**
- Data encryption toggle
- Cloud sync on/off
- Analytics opt-out
- Data retention period

#### App Settings

**Display:**
- Language selection
- Theme (Light/Dark/Auto)
- Font size adjustment
- Color accessibility mode

**Units & Measurements:**
- Metric (kg, cm)
- Imperial (lbs, inches)
- Date format (DD/MM or MM/DD)
- First day of week

**Notifications:**
- Enable/disable types
- Notification time
- Sound selection
- Vibration toggle

---

## 📊 User Flow Diagrams

### 1. Application Entry Flow

```mermaid
flowchart TD
    Start([App Launch]) --> SplashScreen[Splash Screen<br/>3 seconds]
    SplashScreen --> CheckFirstLaunch{First Time<br/>Launch?}
    
    CheckFirstLaunch -->|Yes| LangSelect[Language Selection<br/>EN/SI/TA]
    CheckFirstLaunch -->|No| CheckAuth{User<br/>Logged In?}
    
    LangSelect --> Onboarding[Onboarding Tour<br/>4 Screens]
    Onboarding --> RegScreen[Registration Screen<br/>Required for All Users]
    
    RegScreen --> RegMethod{Registration<br/>Method}
    RegMethod -->|Email| EmailReg[Email Registration<br/>Form]
    RegMethod -->|Phone| PhoneReg[Phone Registration<br/>Form]
    
    EmailReg --> CreateAccount[Create Account<br/>in Local DB]
    PhoneReg --> CreateAccount
    
    CreateAccount --> VerifyChoice{Enable<br/>Data Sync?}
    VerifyChoice -->|Yes| InitVerification[Start Verification<br/>Process]
    VerifyChoice -->|No| SkipVerify[Continue Without<br/>Verification]
    
    InitVerification --> SendVerification{Method}
    SendVerification -->|Email| EmailVerify[Send Email<br/>Verification Link]
    SendVerification -->|Phone| OTPVerify[Send SMS<br/>OTP Code]
    
    EmailVerify --> VerifySuccess{Verification<br/>Success?}
    OTPVerify --> VerifySuccess
    
    VerifySuccess -->|Yes| VerifiedAccount[Account Verified<br/>Cloud Sync Enabled]
    VerifySuccess -->|No| RetryVerify[Retry Verification<br/>or Skip]
    RetryVerify --> VerifySuccess
    
    VerifiedAccount --> AddChild[Add First Child<br/>Screen]
    SkipVerify --> UnverifiedAccount[Unverified Account<br/>Local Only Mode]
    UnverifiedAccount --> AddChild
    
    AddChild --> ChildData[Enter Child Data:<br/>• Name<br/>• DOB<br/>• Gender<br/>• Birth Metrics]
    ChildData --> SaveChild{Save<br/>Success?}
    
    SaveChild -->|Yes| Dashboard[Main Dashboard]
    SaveChild -->|No| ErrorHandler[Show Error<br/>Message]
    ErrorHandler --> ChildData
    
    CheckAuth -->|Yes| LoadUser[Load User Data]
    CheckAuth -->|No| LoginScreen[Login Screen]
    
    LoadUser --> CheckChildren{Has<br/>Children?}
    CheckChildren -->|Yes| Dashboard
    CheckChildren -->|No| AddChild
    
    LoginScreen --> LoginMethod{Login<br/>Method}
    LoginMethod -->|Email| EmailLogin[Email Login]
    LoginMethod -->|Phone| PhoneLogin[Phone Login]
    
    EmailLogin --> AuthValidate{Valid<br/>Credentials?}
    PhoneLogin --> AuthValidate
    
    AuthValidate -->|Yes| LoadUser
    AuthValidate -->|No| LoginError[Show Login Error]
    LoginError --> LoginScreen
    
    GuestMode --> DashboardLimited[Limited Dashboard<br/>No Sync]
    
    Dashboard --> MainApp[Full App Features]
    DashboardLimited --> LimitedApp[Limited Features]
```

### 2. Growth Tracking User Flow

```mermaid
flowchart TD
    DashboardEntry([Dashboard]) --> ActionSelect{User Action}
    
    ActionSelect -->|Add Measurement| AddMeasure[Add Measurement<br/>Screen]
    ActionSelect -->|View Charts| ChartsScreen[Growth Charts<br/>Screen]
    ActionSelect -->|View History| MeasureHistory[Measurement<br/>History]
    
    %% Add Measurement Flow
    AddMeasure --> InputDate[Select/Input Date]
    InputDate --> ValidateDate{Date Valid?<br/>Not Future}
    ValidateDate -->|No| DateError[Show Date Error]
    DateError --> InputDate
    ValidateDate -->|Yes| InputWeight[Enter Weight<br/>kg/lbs]
    
    InputWeight --> InputHeight[Enter Height<br/>cm/inches]
    InputHeight --> CalcBMI[Auto-Calculate<br/>BMI]
    CalcBMI --> AddNotes[Optional Notes<br/>Text Field]
    AddNotes --> SaveButton[Save Measurement]
    
    SaveButton --> ValidateData{All Data<br/>Valid?}
    ValidateData -->|No| ValidationError[Show Validation<br/>Errors]
    ValidationError --> InputWeight
    ValidateData -->|Yes| SaveToDB[(Save to<br/>Local DB)]
    
    SaveToDB --> UpdateProvider[Update Child<br/>Provider]
    UpdateProvider --> CheckSync{Sync<br/>Enabled?}
    CheckSync -->|Yes| QueueSync[Queue for<br/>Cloud Sync]
    CheckSync -->|No| ShowSuccess[Show Success<br/>Message]
    QueueSync --> ShowSuccess
    ShowSuccess --> RefreshDashboard[Refresh Dashboard<br/>Stats]
    
    %% Growth Charts Flow
    ChartsScreen --> SelectChild[Select Child<br/>if Multiple]
    SelectChild --> ChartType{Select Chart<br/>Type}
    
    ChartType -->|Weight| WeightChart[Weight-for-Age<br/>Chart]
    ChartType -->|Height| HeightChart[Height-for-Age<br/>Chart]
    ChartType -->|BMI| BMIChart[BMI-for-Age<br/>Chart]
    
    WeightChart --> LoadData[Load Historical<br/>Measurements]
    HeightChart --> LoadData
    BMIChart --> LoadData
    
    LoadData --> CheckData{Has ≥2<br/>Measurements?}
    CheckData -->|No| NoDataMsg[Show Add More<br/>Measurements Message]
    CheckData -->|Yes| PlotChart[Plot on WHO<br/>Growth Curves]
    
    PlotChart --> ShowPercentile[Display Percentile<br/>Lines & Status]
    ShowPercentile --> EnableInteraction[Enable Touch<br/>Interactions]
    EnableInteraction --> ExportOptions{Export<br/>Options}
    
    ExportOptions -->|PDF| GeneratePDF[Generate PDF<br/>Report]
    ExportOptions -->|Image| GenerateImage[Save Chart<br/>as Image]
    ExportOptions -->|CSV| GenerateCSV[Export Data<br/>as CSV]
    
    %% History Flow
    MeasureHistory --> LoadHistory[Load All<br/>Measurements]
    LoadHistory --> SortByDate[Sort by Date<br/>Descending]
    SortByDate --> DisplayList[Display in<br/>List View]
    DisplayList --> SelectItem{Select<br/>Measurement}
    SelectItem -->|View| ViewDetail[View Details<br/>Screen]
    SelectItem -->|Edit| EditMeasure[Edit Measurement]
    SelectItem -->|Delete| DeleteConfirm{Confirm<br/>Delete?}
    
    DeleteConfirm -->|Yes| DeleteFromDB[(Delete from<br/>Database)]
    DeleteConfirm -->|No| DisplayList
    DeleteFromDB --> RefreshList[Refresh List]
    RefreshList --> DisplayList
```

### 3. Vaccination Management Flow

```mermaid
flowchart TD
    VaccineEntry([Medicine Tab]) --> VaccineHome[Vaccination<br/>Home Screen]
    
    VaccineHome --> ViewOptions{View Option}
    
    ViewOptions -->|Calendar| CalendarView[Calendar View<br/>Monthly Grid]
    ViewOptions -->|List| ListView[List View<br/>Upcoming/Completed]
    ViewOptions -->|Schedule| ScheduleView[Full Schedule<br/>By Age]
    
    %% Calendar View Flow
    CalendarView --> SelectMonth[Select Month<br/>Swipe/Arrows]
    SelectMonth --> ShowVaccines[Display Vaccines<br/>on Calendar]
    ShowVaccines --> TapDate{Tap Date}
    TapDate --> DayDetail[Show Day's<br/>Vaccines]
    
    DayDetail --> VaccineAction{Action}
    VaccineAction -->|Mark Complete| CompleteFlow[Mark as<br/>Completed]
    VaccineAction -->|Set Reminder| ReminderFlow[Set Reminder]
    VaccineAction -->|View Details| DetailView[Vaccine<br/>Information]
    
    %% Complete Vaccine Flow
    CompleteFlow --> EnterDate[Enter Admin<br/>Date]
    EnterDate --> EnterLocation[Enter Location<br/>Optional]
    EnterLocation --> EnterDoctor[Doctor Name<br/>Optional]
    EnterDoctor --> AddNotes[Add Notes<br/>Optional]
    AddNotes --> SaveComplete[Save Record]
    
    SaveComplete --> UpdateDB[(Update<br/>Database)]
    UpdateDB --> UpdateStatus[Change Status<br/>to Completed]
    UpdateStatus --> RemoveReminder[Cancel Any<br/>Reminders]
    RemoveReminder --> RefreshView[Refresh<br/>Calendar]
    
    %% Reminder Flow
    ReminderFlow --> CheckPerm{Notification<br/>Permission?}
    CheckPerm -->|No| RequestPerm[Request<br/>Permission]
    CheckPerm -->|Yes| SelectTime[Select Reminder<br/>Time]
    
    RequestPerm --> PermGranted{Permission<br/>Granted?}
    PermGranted -->|No| ShowError[Show Permission<br/>Required]
    PermGranted -->|Yes| SelectTime
    
    SelectTime --> TimeOptions[1 Week Before<br/>3 Days Before<br/>1 Day Before<br/>On the Day]
    TimeOptions --> SaveReminder[(Save Reminder<br/>to Database)]
    SaveReminder --> ScheduleNotif[Schedule Local<br/>Notification]
    ScheduleNotif --> ShowConfirm[Show Confirmation]
    
    %% List View Flow
    ListView --> FilterOptions{Filter By}
    FilterOptions -->|Upcoming| UpcomingList[Show Upcoming<br/>Vaccines]
    FilterOptions -->|Completed| CompletedList[Show Completed<br/>Vaccines]
    FilterOptions -->|Overdue| OverdueList[Show Overdue<br/>Vaccines]
    
    UpcomingList --> ListInteraction{User Action}
    CompletedList --> ListInteraction
    OverdueList --> ListInteraction
    
    ListInteraction -->|Tap Item| VaccineDetail[Vaccine Details<br/>Screen]
    ListInteraction -->|Quick Complete| QuickComplete[Quick Mark<br/>Complete]
    ListInteraction -->|Export| ExportVaccines[Export Records]
    
    ExportVaccines --> ExportFormat{Format}
    ExportFormat -->|PDF| GenVaccinePDF[Generate Vaccine<br/>Certificate]
    ExportFormat -->|CSV| GenVaccineCSV[Export as<br/>Spreadsheet]
```

---

## 📈 Activity Diagrams

### 1. User Daily Activity Pattern

```mermaid
stateDiagram-v2
    [*] --> AppLaunch: User Opens App
    
    AppLaunch --> Authentication: Check Auth Status
    
    Authentication --> Dashboard: Authenticated
    Authentication --> LoginScreen: Not Authenticated
    
    LoginScreen --> Authentication: Login Success
    LoginScreen --> [*]: Exit App
    
    Dashboard --> ChildSelection: Multiple Children
    Dashboard --> MainActivities: Single Child
    
    ChildSelection --> MainActivities: Child Selected
    
    state MainActivities {
        [*] --> ViewStats: Check Current Stats
        ViewStats --> DecideAction
        
        DecideAction --> AddMeasurement: Time for Update
        DecideAction --> CheckGrowth: Review Progress
        DecideAction --> CheckVaccines: Vaccine Due
        DecideAction --> LearnContent: Read Articles
        
        AddMeasurement --> SaveData
        CheckGrowth --> ViewCharts
        CheckVaccines --> UpdateVaccine
        LearnContent --> ReadArticle
        
        SaveData --> ViewStats
        ViewCharts --> ViewStats
        UpdateVaccine --> ViewStats
        ReadArticle --> ViewStats
    }
    
    MainActivities --> ProfileManage: Manage Profile
    MainActivities --> Settings: App Settings
    MainActivities --> Export: Export Data
    MainActivities --> Sync: Sync to Cloud
    
    ProfileManage --> MainActivities
    Settings --> MainActivities
    Export --> Share: Share Report
    Sync --> MainActivities
    
    Share --> [*]: Complete Session
    MainActivities --> [*]: Exit App
```

### 2. Child Profile Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created: Add Child
    
    Created --> BasicInfo: Enter Name/DOB/Gender
    BasicInfo --> OptionalInfo: Add Birth Metrics
    OptionalInfo --> ProfilePicture: Add Photo
    ProfilePicture --> Active: Save Profile
    
    state Active {
        [*] --> Monitoring
        Monitoring --> GrowthTracking: Regular Updates
        Monitoring --> VaccineTracking: Vaccine Schedule
        Monitoring --> NutritionTracking: Diet Management
        
        GrowthTracking --> DataAnalysis
        VaccineTracking --> DataAnalysis
        NutritionTracking --> DataAnalysis
        
        DataAnalysis --> Monitoring: Continue Tracking
    }
    
    Active --> Edited: Edit Profile
    Edited --> Active: Save Changes
    
    Active --> Archived: Child > 5 Years
    Archived --> Historical: View Only Mode
    
    Active --> Deleted: Remove Profile
    Deleted --> [*]: Data Removed
```

### 3. Data Synchronization Activity

```mermaid
sequenceDiagram
    participant User
    participant App
    participant LocalDB
    participant SyncQueue
    participant CloudAPI
    participant Firebase
    
    User->>App: Perform Action (Add/Edit)
    App->>LocalDB: Save Data Locally
    LocalDB-->>App: Success
    App-->>User: Show Success Message
    
    App->>SyncQueue: Add to Sync Queue
    
    alt Network Available
        SyncQueue->>CloudAPI: Check Connection
        CloudAPI-->>SyncQueue: Connected
        
        SyncQueue->>LocalDB: Get Pending Items
        LocalDB-->>SyncQueue: Return Queue
        
        loop For Each Item
            SyncQueue->>CloudAPI: Send Data
            CloudAPI->>Firebase: Store Data
            Firebase-->>CloudAPI: Confirm
            CloudAPI-->>SyncQueue: Success
            SyncQueue->>LocalDB: Mark as Synced
        end
        
        SyncQueue->>App: Update Sync Status
        App-->>User: Show Sync Icon ✓
        
    else Network Unavailable
        SyncQueue->>App: Queue for Later
        App-->>User: Show Pending Icon ⏳
        
        Note over SyncQueue: Retry Every 30s
        
        SyncQueue->>CloudAPI: Retry Connection
        CloudAPI-->>SyncQueue: Failed
    end
```

### 4. Multi-Child Management Flow

```mermaid
flowchart LR
    subgraph UserAccount[User Account]
        Parent[Parent Profile]
    end
    
    Parent --> Child1[Child 1<br/>0-6 months]
    Parent --> Child2[Child 2<br/>2 years]
    Parent --> Child3[Child 3<br/>4 years]
    
    subgraph Child1Data[Child 1 Data]
        C1Growth[(Growth Records)]
        C1Vaccine[(Vaccine Records)]
        C1Nutrition[(Nutrition Data)]
        C1Photos[(Profile Photos)]
    end
    
    subgraph Child2Data[Child 2 Data]
        C2Growth[(Growth Records)]
        C2Vaccine[(Vaccine Records)]
        C2Nutrition[(Nutrition Data)]
        C2Photos[(Profile Photos)]
    end
    
    subgraph Child3Data[Child 3 Data]
        C3Growth[(Growth Records)]
        C3Vaccine[(Vaccine Records)]
        C3Nutrition[(Nutrition Data)]
        C3Photos[(Profile Photos)]
    end
    
    Child1 --> Child1Data
    Child2 --> Child2Data
    Child3 --> Child3Data
    
    Child1Data --> Analytics1[Individual<br/>Analytics]
    Child2Data --> Analytics2[Individual<br/>Analytics]
    Child3Data --> Analytics3[Individual<br/>Analytics]
    
    Analytics1 --> Comparison[Comparative<br/>Analysis]
    Analytics2 --> Comparison
    Analytics3 --> Comparison
    
    Comparison --> FamilyReport[Family Health<br/>Report]
```

---

## 🏗️ System Architecture

### 1. Application Layer Architecture

```mermaid
graph TB
    subgraph PresentationLayer[Presentation Layer]
        UI[Flutter UI Widgets]
        Screens[Screen Controllers]
        Navigation[GoRouter Navigation]
        Theme[Material 3 Theme]
    end
    
    subgraph BusinessLayer[Business Logic Layer]
        Providers[State Providers]
        Services[Business Services]
        Validators[Input Validators]
        Calculators[Growth Calculators]
    end
    
    subgraph DataLayer[Data Access Layer]
        Repository[Repository Pattern]
        LocalDB[SQLite Database]
        Cache[SharedPreferences]
        FileStorage[File Storage]
    end
    
    subgraph NetworkLayer[Network Layer]
        FirebaseSync[Firebase Sync]
        CloudAPI[REST APIs]
        AuthService[Authentication]
        NotificationService[Push Notifications]
    end
    
    UI --> Screens
    Screens --> Navigation
    Screens --> Providers
    
    Providers --> Services
    Services --> Validators
    Services --> Calculators
    
    Services --> Repository
    Repository --> LocalDB
    Repository --> Cache
    Repository --> FileStorage
    
    Repository --> FirebaseSync
    FirebaseSync --> CloudAPI
    AuthService --> CloudAPI
    NotificationService --> CloudAPI
    
    LocalDB --> SyncQueue[(Sync Queue)]
    SyncQueue --> FirebaseSync
```

### 2. Data Model Architecture

```mermaid
erDiagram
    UserAccount ||--o{ Child : has
    Child ||--o{ GrowthRecord : has
    Child ||--o{ VaccineRecord : has
    Child ||--o{ NutritionData : has
    Child ||--o{ Achievement : earns
    
    UserAccount {
        string id PK
        string fullName
        string phoneNumber
        string email
        string passwordHash
        string photoUrl
        boolean isVerified
        datetime createdAt
        datetime updatedAt
    }
    
    Child {
        string id PK
        string userId FK
        string name
        date birthDate
        string gender
        float birthWeight
        float birthHeight
        string photoUrl
        string medicalNotes
        datetime createdAt
        datetime updatedAt
    }
    
    GrowthRecord {
        string id PK
        string childId FK
        date measurementDate
        float weight
        float height
        float bmi
        string notes
        datetime createdAt
    }
    
    VaccineRecord {
        string id PK
        string childId FK
        string vaccineId
        string vaccineName
        date scheduledDate
        date completedDate
        string status
        string location
        string doctor
        string notes
    }
    
    NutritionData {
        string id PK
        string childId FK
        date date
        string mealType
        string foodItems
        int calories
        float protein
        float carbs
        float fats
    }
    
    Achievement {
        string id PK
        string childId FK
        string type
        string title
        string description
        string rarity
        int points
        datetime unlockedAt
    }
```

### 3. Navigation Architecture

```mermaid
graph TD
    SplashScreen[Splash Screen]
    
    SplashScreen --> LanguageSelection[Language Selection]
    SplashScreen --> LoginCheck{Auth Check}
    
    LanguageSelection --> Onboarding[Onboarding]
    Onboarding --> Registration[Registration]
    
    LoginCheck --> Login[Login Screen]
    LoginCheck --> MainApp[Main App]
    
    Registration --> Verification[Verification]
    Verification --> AddChild[Add Child]
    
    Login --> ForgotPassword[Forgot Password]
    Login --> MainApp
    
    AddChild --> MainApp
    
    MainApp --> TabNavigator{Bottom Tabs}
    
    TabNavigator --> Home[Home/Dashboard]
    TabNavigator --> Growth[Growth Charts]
    TabNavigator --> Medicine[Vaccines]
    TabNavigator --> Learn[Education]
    TabNavigator --> Profile[Profile]
    
    Home --> AddMeasurement[Add Measurement]
    Home --> GrowthCountdown[6-Month Countdown]
    Home --> ProgressTracking[Progress Analytics]
    Home --> Achievements[Achievements]
    
    Growth --> ChartDetail[Chart Details]
    Growth --> ExportData[Export Options]
    
    Medicine --> VaccineCalendar[Calendar View]
    Medicine --> VaccineDetail[Vaccine Details]
    Medicine --> AddHealthRecord[Health Records]
    
    Learn --> NutritionGuide[Nutrition Guide]
    Learn --> ArticleDetail[Article Detail]
    Learn --> MealPlanner[Meal Planner]
    
    Profile --> EditProfile[Edit Profile]
    Profile --> Settings[Settings]
    Profile --> EditChild[Edit Child]
    Profile --> About[About Aayu]
```

### 4. Security & Privacy Architecture

```mermaid
flowchart TB
    subgraph UserData[User Data]
        PersonalInfo[Personal Information]
        ChildData[Child Data]
        HealthRecords[Health Records]
        Photos[Profile Photos]
    end
    
    subgraph SecurityLayers[Security Layers]
        Authentication[Authentication Layer]
        Encryption[Encryption Layer]
        Authorization[Authorization Layer]
        DataValidation[Data Validation]
    end
    
    subgraph Storage[Storage]
        LocalStorage[Local Storage<br/>SQLite + Encrypted]
        CloudStorage[Cloud Storage<br/>Firebase]
        FileSystem[File System<br/>Profile Images]
    end
    
    UserData --> Authentication
    Authentication --> Encryption
    Encryption --> Authorization
    Authorization --> DataValidation
    
    DataValidation --> LocalStorage
    LocalStorage --> SyncEngine[Sync Engine]
    SyncEngine --> CloudStorage
    
    Photos --> FileSystem
    FileSystem --> Compression[Image Compression]
    Compression --> LocalStorage
    
    subgraph PrivacyControls[Privacy Controls]
        DataMinimization[Data Minimization]
        UserConsent[User Consent]
        DataDeletion[Right to Delete]
        DataExport[Data Portability]
    end
    
    SecurityLayers --> PrivacyControls
    PrivacyControls --> Storage
```

### 5. Performance Optimization Architecture

```mermaid
graph TD
    subgraph OptimizationLayers[Optimization Strategies]
        LazyLoading[Lazy Loading]
        Caching[Data Caching]
        ImageOpt[Image Optimization]
        CodeSplitting[Code Splitting]
    end
    
    subgraph CacheStrategy[Cache Strategy]
        MemoryCache[In-Memory Cache]
        DiskCache[Disk Cache]
        NetworkCache[Network Cache]
    end
    
    subgraph ImageHandling[Image Handling]
        Compression[JPEG Compression]
        Resizing[Dynamic Resizing]
        LazyLoad[Lazy Image Loading]
        Thumbnails[Thumbnail Generation]
    end
    
    subgraph DataManagement[Data Management]
        Pagination[Data Pagination]
        IndexedDB[Indexed Database]
        QueryOpt[Query Optimization]
        BatchOps[Batch Operations]
    end
    
    OptimizationLayers --> CacheStrategy
    OptimizationLayers --> ImageHandling
    OptimizationLayers --> DataManagement
    
    CacheStrategy --> Performance[App Performance]
    ImageHandling --> Performance
    DataManagement --> Performance
    
    Performance --> Metrics{Performance Metrics}
    Metrics --> LoadTime[< 3s Load Time]
    Metrics --> Responsiveness[< 100ms Response]
    Metrics --> MemoryUsage[< 150MB RAM]
```

---

## 📱 Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider Pattern
- **Navigation**: GoRouter
- **UI Components**: Material Design 3
- **Localization**: Flutter Intl

### Backend Services
- **Authentication**: Firebase Auth / Local Auth
- **Database**: SQLite (Local) + Firestore (Cloud)
- **Storage**: Local File System + Firebase Storage
- **Sync**: Custom Sync Engine with Queue
- **Notifications**: Firebase Cloud Messaging

### Development Tools
- **IDE**: Android Studio / VS Code
- **Version Control**: Git
- **CI/CD**: GitHub Actions
- **Testing**: Flutter Test Framework
- **Analytics**: Firebase Analytics

### Libraries & Packages
- **Charts**: fl_chart
- **Images**: image_picker, path_provider
- **Database**: sqflite
- **HTTP**: dio
- **Preferences**: shared_preferences
- **Security**: flutter_secure_storage
- **Notifications**: flutter_local_notifications

---

**Thank you for choosing Aayu to support your child's healthy growth and development! 🌟**

*Made with ❤️ in Sri Lanka by Akash Hasendra*

---

*Document Version: 2.0.0 - Technical Edition*  
*Last Updated: August 2025*  
*For Aayu App Version: 1.0.0*