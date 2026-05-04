import SwiftUI
import AVFoundation

struct CardGameView: View {
    @Environment(\.dismiss) private var dismiss  // Add this for navigation
    let userLanguage: LanguageSelectionView.Language
    let topic: TopicSelectionView.Topic
    @ObservedObject var scoreManager: ScoreManager
    
    @State private var currentCardIndex = 0
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var answerOptions: [(String, String)] = []  // Array to hold answer options
    @State private var canMoveToNext = false  // Add this state variable
    @State private var completedCards: Set<Int> = []
    @State private var correctAnswer: String? = nil  // Add this to track correct answer
    @State private var wrongAnswer: String? = nil  // Add this to track wrong answer
    @State private var savedAnswerOptions: [Int: [(String, String)]] = [:]
    @State private var feedbackMessage: String? = nil
    @State private var showAnswerButtons: [Bool] = [false, false, false]  // Track visibility of each answer button
    @State private var showSoundButtons: [Bool] = [false, false, false]   // Track visibility of each sound button
    @State private var shuffledCards: [(String, String)] = []
    @State private var showConfetti = false
    @State private var correctCards: Set<Int> = []  // For immediate green coloring
    @State private var seenCards: Set<Int> = []  // Track which cards have been seen
    @State private var showScoreAnimation = false
    @State private var showCompletionPopup = false
    @State private var currentCardAttempts: Int = 0
    @State private var currentPoints: Int = 0  // Add this with other @State variables
    @State private var isGlowing = false
    @State private var glowingButtonIndex: Int? = nil
    
    // English to Swedish cards
    let englishCards: [String: [(word: String, translation: String)]] = [
        "animals": [
            ("Dog", "Hund"),
            ("Cat", "Katt"),
            ("Fish", "Fisk"),
            ("Chick", "Kyckling"),
            ("Camel", "Kamel"),
            ("Wolf", "Varg"),
            ("Pig", "Gris"),
            ("Yak", "Jak"),
            ("Dove", "Duva"),
            ("Shark", "Haj"),
            ("Snake", "Orm"),
            ("Eagle", "Örn"),
            ("Squirrel", "Ekorre"),
            ("Bat", "Fladdermus"),
            ("Mouse", "Mus"),
            ("Elephant", "Elefant"),
            ("Penguin", "Pingvin"),
            ("Cow", "Ko"),
            ("Turtle", "Sköldpadda"),
            ("Frog", "Groda"),
            ("Hedgehog", "Igelkott"),
            ("Rhino", "Noshörning"),
            ("Parrot", "Papegoja"),
            ("Horse", "Häst"),
        ],
        
        "food": [
            ("Bread", "Bröd"),
            ("Milk", "Mjölk"),
            ("Burger", "Hamburgare"),
            ("Cake", "Tårta"),
            ("Candy", "Godis"),
            ("Cheese", "Ost"),
            ("Honey", "Honung"),
            ("Jam", "Sylt"),
            ("Juice", "Juice "),
            ("Noodles", "Spaghetti"),
            ("Nutella", "Nutella "),
            ("Pasta", "Pasta "),
            ("Quiche", "Quiche "),
            ("Soup", "Soppa"),
            ("Yoghurt", "Yoghurt "),
            ("Meat", "Kött"),
            ("Chocolate", "Choklad"),
            ("Coffee", "Kaffe"),
            ("Cereals", "Flingor"),
            ("Rice", "Ris"),
            ("Hot dog", "Varmkorv"),
            ("Ice cream", "Glass "),
        ],
        
        "FruitAndVegetables": [
            ("Apple", "Äpple"),
            ("Potato", "Potatis"),
            ("Banana", "Banan"),
            ("Beetroot", "Rödbeta"),
            ("Garlic", "Vitlök"),
            ("Carrot", "Morot"),
            ("Coconut", "Kokosnöt"),
            ("Cucumber", "Gurka"),
            ("Corn", "Majs"),
            ("Eggplant", "Äggplanta"),
            ("Grapes", "Druvor"),
            ("Lemon", "Citron"),
            ("Mango", "Mango "),
            ("Nectarine", "Nektarin"),
            ("Olive", "Oliv"),
            ("Onion", "Lök"),
            ("Orange", "Apelsin"),
            ("Pear", "Päron"),
            ("Tomato", "Tomat"),
            ("Walnut", "Valnöt"),
            ("Watermelon", "Vattenmelon"),
            ("Zucchini", "Zucchini "),
        ],
        
        "colors": [
            ("Red", "Röd"),
            ("Blue", "Blå"),
            ("Green", "Grön"),
            ("Yellow", "Gul"),
            ("Orange_", "Orange "),
            ("Pink", "Rosa"),
            ("Purple", "Lila"),
            ("White", "Vit"),
            ("Brown", "Brun"),
            ("Gray", "Grå"),
            ("Black", "Svart"),
        ],
        
        "numbers": [
            ("One", "Ett"),
            ("Two", "Två"),
            ("Three", "Tre"),
            ("Four", "Fyra"),
            ("Five", "Fem"),
            ("Six", "Sex"),
            ("Seven", "Sju"),
            ("Eight", "Åtta"),
            ("Nine", "Nio"),
            ("Zero", "Noll"),
        ],
        
        "transportation": [
            ("Car", "Bil"),
            ("Train", "Tåg"),
            ("Ambulance", "Ambulans"),
            ("Boat", "Båt"),
            ("Bus", "Buss"),
            ("Airplain", "Flygplan"),
            ("Yacht", "Lyxbåt"),
            ("Bicycle", "Cykel"),
            ("Motorcycle", "Motorcykel"),
            ("Tram", "Spårvagn"),
            ("Subway", "Tunnelbana"),
            ("Ferry", "Färja"),
            ("Scooter", "Skoter"),
            ("Truck", "Lastbil"),
            ("Submarine", "Ubåt"),
            ("Ship", "Skepp"),
        ],
        
        "inTheHouse": [
            ("Lamp", "Lampa"),
            ("Chair", "Stol"),
            ("Sofa", "Soffa"),
            ("Bed", "Säng"),
            ("Mattress", "Madrass"),
            ("Blanket", "Filt"),
            ("Pillow", "Kudde"),
            ("Carpet", "Matta"),
            ("Curtain", "Gardiner"),
            ("Remote control", "Fjärrkontroll"),
            ("Shelf", "Hylla"),
            ("Mirror", "Spegel"),
            ("Toilet", "Toalett"),
            ("Bathtub", "Badkar"),
            ("Shower", "Dusch"),
            ("Toothbrush", "Tandborste"),
            ("Toothpaste", "Tandkräm"),
            ("Shampoo", "Schampo"),
            ("Door", "Dörr"),
            ("Window", "Fönster"),
            ("Balcony", "Balkong"),
            ("Key", "Nyckel"),
            ("Washing machine", "Tvättmaskin"),
        ],
        
        "seasons": [
            ("Spring", "Våren"),
            ("Summer", "Sommaren"),
            ("Fall", "Hösten"),
            ("Winter", "Vintern"),
            ("Snow", "Snö"),
            ("Snowman", "Snögubbe"),
            ("Sledge", "Kälke"),
            ("Ice", "Is"),
            ("Mittens", "Vantar"),
            ("Wind", "Vind"),
            ("Leaf", "Löv"),
            ("Sun", "Sol"),
            ("Beach", "Strand"),
            ("Swimsuit", "Baddräkt"),
            ("Scarf", "Halsduk"),
            ("Boots", "Stövlar"),
            ("Snowflake", "Snöflinga"),
            ("Ski", "Skida"),
            ("Snowball", "Snöboll"),
            ("Cold", "Kallt"),
            ("Sunglasses", "Solglasögon"),
            ("Rain", "Regn"),
            ("Cloud", "Moln"),
            ("Lightning", "Blixt"),
        ],
        
        "electric": [
            ("Computer", "Dator"),
            ("Mobile phone", " Mobiltelefon"),
            ("Tablet", "Surfplatta"),
            ("Speaker", "Högtalare"),
            ("Microphone", "Mikrofon"),
            ("Battery", "Batteri"),
            ("Printer", "Skrivare"),
            ("Keyboard", "Tangentbord"),
            ("Monitor", "Skärm"),
            ("Coffee machine", "Kaffemaskin"),
            ("Vacuum cleaner", "Dammsugare"),
            ("Washing machine", "Tvättmaskin"),
            ("Microwave", "Mikrovågsugn"),
            ("Dishwasher", "Diskmaskin"),
            ("Remote control", "Fjärrkontroll"),
            ("Toaster", "Brödrost"),
            ("Hair dryer", "Hårtork"),
            ("Air conditioner", "Luftkonditionering"),
            ("Headphones", "Hörlurar"),
            ("Mixer", "Matberedare"),
            ("Light bulb", "Glödlampa"),
        ],
        
        "kitchen": [
            ("Kitchen", "Kök"),
            ("Knife", "Kniv"),
            ("Fork", "Gaffel"),
            ("Stove", "Spis"),
            ("Oven", "Ugn"),
            ("Fridge", "Kylskåp"),
            ("Freezer", "Frys"),    
            ("Microwave", "Mikrovågsugn"),
            ("Sink", "Diskho"),
            ("Dishwasher", "Diskmaskin"),
            ("Table", "Bord"),
            ("Chair", "Stol"),
            ("Spoon", "Sked"),
            ("Teaspoon", "Tesked"),
            ("Plate", "Tallrik"),
            ("Bowl", "Skål"),
            ("Glass", "Glas"),
            ("Pot", "Kastrull"),
            ("Pan", "Stekpanna"),
            ("Cutting board", "Skärbräda"),
            ("Towel", "Kökshandduk"),
        ],
        
        "nature": [
            ("Tree", "Träd"),
            ("Flower", "Blomma"),
            ("Forest", "Skog"),
            ("Mountain", "Berg"),
            ("River", "Flod"),
            ("Lake", "Sjö"),
            ("Sea", "Hav"),
            ("Stone", "Sten"),
            ("Moon", "Måne"),
            ("Desert", "Öken"),
            ("Waterfall", "Vattenfall"),
            ("Sunset", "Solnedgång"),
            ("Sunrise", "Soluppgång"),
            ("Swamp", "Träsk"),
            ("Volcano", "Vulkan"),
            ("Seashell", "Snäckskal"),
            ("Dune", "Sanddyn"),
        ],
        
        "humanBody": [
            ("Head", "Huvud"),
            ("Hair", "Hår"),
            ("Face", "Ansikte"),
            ("Ear", "Öra"),
            ("Nose", "Näsa"),
            ("Mouth", "Mun"),
            ("Tooth", "Tand"),
            ("Tongue", "Tunga"),
            ("Neck", "Hals"),
            ("Shoulder", "Axel"),
            ("Elbow", "Armbåge"),
            ("Hand", "Hand "),
            ("Finger", "Finger "),
            ("Stomach", "Mage"),
            ("Leg", "Ben"),
            ("Knee", "Knä"),
            ("Foot", "Fot"),
            ("Heart", "Hjärta"),
            ("Brain", "Hjärna"),
            ("Eyebrow", "Ögonbryn"),
            ("Chin", "Haka"),
            ("Beard", "Skägg"),
            ("Mustache", "Mustasch"),
            ("Nail", "Nagel"),
            ("Eye", "Öga"),
            ("Forehead", "Panna"),
            ("Back", "Rygg"),
        ]
    ]
    
    // Hebrew to Swedish cards
    let hebrewCards: [String: [(word: String, translation: String)]] = [
        "animals": [
            ("כלב", "Hund"),
            ("חתול", "Katt"),
            ("סוס", "Häst"),
            ("דג", "Fisk"),
            ("אפרוח", "Kyckling"),
            ("גמל", "Kamel"),
            ("זאב", "Varg"),
            ("חזיר", "Gris"),
            ("יאק", "Jak"),
            ("יונה", "Duva"),
            ("כריש", "Haj"),
            ("נחש", "Orm"),
            ("נשר", "Örn"),
            ("סנאי", "Ekorre"),
            ("עטלף", "Fladdermus"),
            ("עכבר", "Mus"),
            ("פיל", "Elefant"),
            ("פינגוין", "Pingvin"),
            ("פרה", "Ko"),
            ("צב", "Sköldpadda"),
            ("צפרדע", "Groda"),
            ("קיפוד", "Igelkott"),
            ("קרנף", "Noshörning"),
            ("תוכי", "Papegoja"),
        ],
        
        "food": [
            ("לחם", "Bröd"),
            ("חלב", "Mjölk"),
            ("המבורגר", "Hamburgare"),
            ("עוגה", "Tårta"),
            ("סוכריה", "Godis"),
            ("גבינה", "Ost"),
            ("דבש", "Honung"),
            ("ריבה", "Sylt"),
            ("מיץ", "Juice "),
            ("נודלס", "Spaghetti"),
            ("נוטלה", "Nutella "),
            ("פסטה", "Pasta "),
            ("קיש", "Quiche "),
            ("מרק", "Soppa"),
            ("יוגורט", "Yoghurt "),
            ("בשר", "Kött"),
            ("שוקולד", "Choklad"),
            ("קפה", "Kaffe"),
            ("דגנים", "Flingor"),
            ("אורז", "Ris"),
            ("נקניקיה", "Varmkorv"),
            ("גלידה", "Glass "),
        ],
        
        "FruitAndVegetables": [
            ("תפוח", "Äpple"),
            ("תפוח אדמה", "Potatis"),
            ("בננה", "Banan"),
            ("שום", "Vitlök"),
            ("סלק", "Rödbeta"),
            ("גזר", "Morot"),
            ("קוקוס", "Kokosnöt"),
            ("מלפפון", "Gurka"),
            ("תירס", "Majs"),
            ("חציל", "Äggplanta"),
            ("ענבים", "Druvor"),
            ("לימון", "Citron"),
            ("מנגו", "Mango "),
            ("נקטרינה", "Nektarin"),
            ("זית", "Oliv"),
            ("בצל", "Lök"),
            ("תפוז", "Apelsin"),
            ("אגס", "Päron"),
            ("עגבניה", "Tomat"),
            ("אגוז", "Valnöt"),
            ("אבטיח", "Vattenmelon"),
            ("זוקיני", "Zucchini "),
        ],

        "colors": [
            ("אדום", "Röd"),
            ("כחול", "Blå"),
            ("ירוק", "Grön"),
            ("צהוב", "Gul"),
            ("כתום", "Orange "),
            ("ורוד", "Rosa"),
            ("סגול", "Lila"),
            ("לבן", "Vit"),
            ("חום", "Brun"),
            ("אפור", "Grå"),
            ("שחור", "Svart"),
        ],
        
        "numbers": [
            ("אחת", "Ett"),
            ("שתיים", "Två"),
            ("שלוש", "Tre"),
            ("ארבע", "Fyra"),
            ("חמש", "Fem"),
            ("שש", "Sex"),
            ("שבע", "Sju"),
            ("שמונה", "Åtta"),
            ("תשע", "Nio"),
            ("אפס", "Noll"),
        ],
        
        "transportation": [
            ("מכונית", "Bil"),
            ("רכבת", "Tåg"),
            ("אמבולנס", "Ambulans"),
            ("סירה", "Båt"),
            ("אוטובוס", "Buss"),
            ("מטוס", "Flygplan"),
            ("יאכטה", "Lyxbåt"),
            ("אופניים", "Cykel"),
            ("אופנוע", "Motorcykel"),
            ("רכבת קלה", "Spårvagn"),
            ("רכבת תחתית", "Tunnelbana"),
            ("מעבורת", "Färja"),
            ("קורקינט", "Skoter"),
            ("משאית", "Lastbil"),
            ("צוללת", "Ubåt"),
            ("ספינה", "Skepp"),
        ],
        
        "inTheHouse": [
            ("מנורה", "Lampa"),
            ("כיסא", "Stol"),
            ("ספה", "Soffa"),
            ("מיטה", "Säng"),
            ("מזרן", "Madrass"),
            ("שמיכה", "Filt"),
            ("כרית", "Kudde"),
            ("שטיח", "Matta"),
            ("וילון", "Gardiner"),
            ("שלט", "Fjärrkontroll"),
            ("מדף", "Hylla"),
            ("מראה", "Spegel"),
            ("שירותים", "Toalett"),
            ("אמבטיה", "Badkar"),
            ("מקלחת", "Dusch"),
            ("מברשת שיניים", "Tandborste"),
            ("משחת שיניים", "Tandkräm"),
            ("שמפו", "Schampo"),
            ("דלת", "Dörr"),
            ("חלון", "Fönster"),
            ("מרפסת", "Balkong"),
            ("מפתח", "Nyckel"),
            ("מכונת כביסה", "Tvättmaskin"),
        ],
        
        "seasons": [
            ("אביב", "Våren"),
            ("קיץ", "Sommaren"),
            ("סתיו", "Hösten"),
            ("חורף", "Vintern"),
            ("שלג", "Snö"),
            ("איש שלג", "Snögubbe"),
            ("מזחלת", "Kälke"),
            ("קרח", "Is"),
            ("כפפות", "Vantar"),
            ("רוח", "Vind"),
            ("עלה", "Löv"),
            ("שמש", "Sol"),
            ("חוף", "Strand"),
            ("בגד ים", "Baddräkt"),
            ("צעיף", "Halsduk"),
            ("מגפיים", "Stövlar"),
            ("פתית שלג", "Snöflinga"),
            ("סקי", "Skida"),
            ("כדור שלג", "Snöboll"),
            ("קור", "Kallt"),
            ("משקפי שמש", "Solglasögon"),
            ("גשם", "Regn"),
            ("ענן", "Moln"),
            ("ברק", "Blixt"),
        ],
        
        "electric": [
            ("מחשב", "Dator"),
            ("טלפון סלולרי", "Mobiltelefon"),
            ("טאבלט", "Surfplatta"),
            ("רמקול", "Högtalare"),
            ("מיקרופון", "Mikrofon"),
            ("סוללה", "Batteri"),
            ("מדפסת", "Skrivare"),
            ("מקלדת", "Tangentbord"),
            ("מסך", "Skärm"),
            ("מכונת קפה", "Kaffemaskin"),
            ("שואב אבק", "Dammsugare"),
            ("מכונת כביסה", "Tvättmaskin"),
            ("מיקרוגל", "Mikrovågsugn"),
            ("מדיח כלים", "Diskmaskin"),
            ("שלט", "Fjärrkontroll"),
            ("טוסטר", "Brödrost"),
            ("מייבש שיער", "Hårtork"),
            ("מזגן", "Luftkonditionering"),
            ("מיקסר", "Matberedare"),
            ("נורה", "Glödlampa"),
        ],
        
        "kitchen": [
            ("מטבח", "Kök"),
            ("סכין", "Kniv"),
            ("מזלג", "Gaffel"),
            ("כיריים", "Spis"),
            ("תנור", "Ugn"),
            ("מקרר", "Kylskåp"),
            ("מקפיא", "Frys"),
            ("מיקרוגל", "Mikrovågsugn"),
            ("כיור", "Diskho"),
            ("מדיח כלים", "Diskmaskin"),
            ("שולחן", "Bord"),
            ("כיסא", "Stol"),
            ("כף", "Sked"),
            ("כפית", "Tesked"),
            ("צלחת", "Tallrik"),
            ("קערה", "Skål"),
            ("כוס", "Glas"),
            ("סיר", "Kastrull"),
            ("מחבת", "Stekpanna"),
            ("קרש חיתוך", "Skärbräda"),
            ("מגבת", "Kökshandduk"),
        ],
        
        "nature": [
            ("עץ", "Träd"),
            ("פרח", "Blomma"),
            ("יער", "Skog"),
            ("הר", "Berg"),
            ("נהר", "Flod"),
            ("אגם", "Sjö"),
            ("ים", "Hav"),
            ("אבן", "Sten"),
            ("ירח", "Måne"),
            ("מדבר", "Öken"),
            ("מפל", "Vattenfall"),
            ("שקיעה", "Solnedgång"),
            ("זריחה", "Soluppgång"),
            ("ביצה", "Träsk"),
            ("הר געש", "Vulkan"),
            ("קונכיה", "Snäckskal"),
            ("דיונה", "Sanddyn"),
        ],
        
        "humanBody": [
            ("ראש", "Huvud"),
            ("שיער", "Hår"),
            ("פנים", "Öga"),
            ("אוזן", "Öra"),
            ("אף", "Näsa"),
            ("פה", "Mun"),
            ("שן", "Tand"),
            ("לשון", "Tunga"),
            ("צואר", "Hals"),
            ("כתף", "Axel"),
            ("מרפק", "Armbåge"),
            ("כף יד", "Hand "),
            ("אצבע", "Finger "),
            ("בטן", "Mage"),
            ("רגל", "Ben"),
            ("ברך", "Knä"),
            ("כף רגל", "Fot"),
            ("לב", "Hjärta"),
            ("מוח", "Hjärna"),
            ("גבה", "Ögonbryn"),
            ("סנטר", "Haka"),
            ("זקן", "Skägg"),
            ("שפם", "Mustasch"),
            ("ציפורן", "Nagel"),
            ("עין", "Öga"),
            ("מצח", "Panna"),
            ("גב", "Rygg"),
        ]
    ]
    
    var currentCards: [(String, String)] {
        shuffledCards
    }
    
    var currentImageName: String {
        guard !shuffledCards.isEmpty, currentCardIndex < shuffledCards.count else {
            return "placeholder"  // Return a default image name or empty string
        }
        let word = currentCards[currentCardIndex].0
        return word
    }
    
    func playElementSound() {
        let soundFolder = userLanguage == .english ? "SoundsEn" : "SoundsHe"
        let soundName = currentCards[currentCardIndex].0
        
        if let path = Bundle.main.path(forResource: soundName, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not play sound file: \(error)")
            }
        } else {
            print("Could not find sound file: \(soundName).mp3")
        }
    }
    
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // Add computed property to check if current card is completed
    private var isCurrentCardCompleted: Bool {
        completedCards.contains(currentCardIndex)
    }
    
    var body: some View {
        ZStack {
            // Background and main content
            ZStack {
                Image("Sweden6")
                    .resizable()
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    // Card and navigation area (fixed position)
                    ZStack {
                        // Card display area
                        ZStack {
                            RoundedRectangle(cornerRadius: isIPhone ? 10 : 15)
                                .fill(correctCards.contains(currentCardIndex) ? Color.green.opacity(0.9) : Color.white.opacity(0.9))
                                .frame(width: isIPhone ? geometry.size.width * 0.40 : geometry.size.width * 0.52,
                                       height: isIPhone ? geometry.size.height * 0.55 : geometry.size.height * 0.55)
                                .onTapGesture {
                                    playElementSound()
                                }
                            
                            Image(currentImageName, bundle: nil)
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? geometry.size.width * 0.50 : geometry.size.width * 0.47,
                                       height: isIPhone ? geometry.size.height * 0.50 : geometry.size.height * 0.50)
                                .onTapGesture {
                                    playElementSound()
                                }
                            
                            // Add volume icon overlay with tap gesture
                            Image("volume2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? 50 : 90)
                                .shadow(color: isGlowing ? .white.opacity(0.8) : .clear, radius: isGlowing ? 40 : 0)
                                .scaleEffect(isGlowing ? 1.3 : 1.0)  // Add scale effect
                                .offset(x: isIPhone ? 145 : 290, y: 0)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isGlowing = true
                                    }
                                    playElementSound()
                                    // Reset glow after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation {
                                            isGlowing = false
                                        }
                                    }
                                }
                        }
                        .position(x: isIPhone ? geometry.size.width/2 : geometry.size.width/2,
                                  y: isIPhone ? geometry.size.height * 0.30 : geometry.size.height * 0.29)
                        
                        // Navigation buttons
                        HStack(spacing: 20) {
                            // Previous button
                            ZStack {
                                if currentCardIndex > 0 {
                                    Button(action: {
                                        currentCardIndex -= 1
                                        scoreManager.saveCardPosition(currentCardIndex, for: topic)
                                        generateAnswerOptions()
                                        canMoveToNext = completedCards.contains(currentCardIndex)
                                    }) {
                                        Image("previous")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: isIPhone ? 80 : 100)
                                            .shadow(color: .black, radius: 8)
                                            .shadow(radius: 9)
                                    }
                                    .buttonStyle(NoAnimationButtonStyle())
                                    .transition(.scaleAndFade)
                                    .animation(.easeInOut, value: currentCardIndex)
                                }
                            }
                            .frame(width: isIPhone ? 80 : 100)
                            .padding(.leading, isIPhone ? 60 : 50)
                            
                            Spacer()
                            
                            // Next button
                            ZStack {
                                if currentCardIndex < currentCards.count - 1 && (canMoveToNext || isCurrentCardCompleted) {
                                    Button(action: {
                                        if correctCards.contains(currentCardIndex) {
                                            completedCards.insert(currentCardIndex)
                                            scoreManager.markCardCompleted(currentCardIndex, for: topic)
                                            if !scoreManager.getCompletedCards(for: topic).contains(currentCardIndex) {
                                                scoreManager.correctAnswers += 1
                                            }
                                        }
                                        currentCardIndex += 1
                                        scoreManager.saveCardPosition(currentCardIndex, for: topic)
                                        generateAnswerOptions()
                                        checkTopicCompletion()
                                    }) {
                                        Image("next")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: isIPhone ? 80 : 100)
                                            .shadow(color: .black, radius: 8)
                                            .shadow(radius: 9)
                                    }
                                    .buttonStyle(NoAnimationButtonStyle())
                                    .disabled(!canMoveToNext && !isCurrentCardCompleted)
                                    .transition(.slideAndFade)
                                    .animation(.easeInOut(duration: 0.5), value: canMoveToNext)
                                }
                            }
                            .frame(width: isIPhone ? 45 : 65)
                            .padding(.trailing, isIPhone ? 70 : 70)
                        }
                        .padding(.horizontal, isIPhone ? 20 : 40)
                        .position(x: geometry.size.width/2, y: isIPhone ? geometry.size.height * 0.40 : geometry.size.height * 0.29)
                    }
                    
                    // Answer buttons area (separate from card)
                    ZStack {
                        // Answer buttons in their own VStack
                        VStack {
                            Spacer()
                            
                            // Answer buttons
                            HStack(spacing: 20) {
                                ForEach(Array(answerOptions.enumerated()), id: \.element.0) { index, option in
                                    VStack(spacing: isIPhone ? -10 : 0) {
                                        // Container for sound button with fixed height
                                        ZStack {
                                            if showSoundButtons[index] {
                                                Button(action: {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        glowingButtonIndex = index
                                                    }
                                                    playSwedishSound(option.1)
                                                    // Reset glow after animation
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        withAnimation {
                                                            glowingButtonIndex = nil
                                                        }
                                                    }
                                                }) {
                                                    Image("volume2")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: isIPhone ? 50 : 90)
                                                        .shadow(color: glowingButtonIndex == index ? .white.opacity(0.8) : .clear, radius: glowingButtonIndex == index ? 40 : 0)
                                                        .scaleEffect(glowingButtonIndex == index ? 1.3 : 1.0)  // Add scale effect
                                                }
                                                .transition(.scaleAndFade)
                                                .buttonStyle(NoAnimationButtonStyle())
                                            }
                                        }
                                        .frame(height: isIPhone ? 80 : 120)
                                        
                                // Answer button below
                                if showAnswerButtons[index] {
                                    Button(action: {
                                        checkAnswer(option.1)
                                    }) {
                                        Text(option.1)
                                            .font(.system(size: option.1.count >= 17 ? (isIPhone ? 20 : 33) : (isIPhone ? 20 : 40), weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: isIPhone ? 220 : 320, height: isIPhone ? 60 : 120)
                                            .background(
                                                correctCards.contains(currentCardIndex) && option.1 == correctAnswer
                                                ? Color.green.opacity(0.9)
                                                    : option.1 == wrongAnswer
                                                ? Color.red.opacity(0.8)
                                                        : Color.blue
                                            )
                                            .cornerRadius(isIPhone ? 10 : 20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: isIPhone ? 10 : 20)
                                                    .stroke(Color.black.opacity(0.3), lineWidth: isIPhone ? 3 : 5)
                                            )
                                    }
                                    .buttonStyle(NoAnimationButtonStyle())
                                    .transition(.scaleAndFade)
                                    .disabled(correctCards.contains(currentCardIndex))
                                }
                            }
                        }
                    }
                            .animation(.easeInOut(duration: 0.5), value: showAnswerButtons)
                            .animation(.easeInOut(duration: 0.5), value: showSoundButtons)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom, isIPhone ? 15 : 50)
                        }
                        
                        // Feedback message with its own positioning
                        VStack {
                            Spacer()
                            if let message = feedbackMessage {
                                Text(message)
                                    .font(.system(size: isIPhone ? 20 : 50, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(isCorrect ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                    )
                                    .transition(.opacity)
                                    .padding(.bottom, isIPhone ? 140 : 300)  // Adjust this value to position the feedback
                            }
                        }
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ProgressCountView(
                        completedCount: completedCards.count,
                        totalCount: currentCards.count,
                        isIPhone: isIPhone
                    )
                    .position(
                        x: geometry.size.width/2,
                        y: isIPhone ? geometry.size.height * 0.05 : geometry.size.height * 0.05
                    )
                }
                .ignoresSafeArea()
            }
            
            // Overlay home and score buttons
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image("home")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIPhone ? 25 : 38)
                        }
                        .foregroundColor(.white)
                        .frame(
                            width: isIPhone ? 120 : 170,
                            height: isIPhone ? 48 : 65
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.8), lineWidth: isIPhone ? 8 : 10)
                        )
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .buttonStyle(NoAnimationButtonStyle())
                    
                    Spacer()
                    
                    ScoreView(scoreManager: scoreManager)
                }
                .padding(.top, 10)
                .padding(.horizontal, 30)
                Spacer()
            }
            
            // Score animation overlay
            if showScoreAnimation {
                GeometryReader { geometry in
                    ScoreUpdateView(points: currentPoints) {
                        showScoreAnimation = false
                    }
                    .position(
                        x: geometry.size.width - 110,
                        y: 170
                    )
                    .zIndex(1)
                }
            }
            
            // Add completion popup
            if showCompletionPopup {
                TopicCompletionPopup(
                    userLanguage: userLanguage,
                    topic: topic,
                    scoreManager: scoreManager,
                    onAppear: {
                        // Play CompletedTopic sound first
                        let soundFile = userLanguage == .english ? "CompletedTopicEn" : "CompletedTopicHe"
                        if let path = Bundle.main.path(forResource: soundFile, ofType: "mp3") {
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                                audioPlayer?.play()
                                
                                // After 2 seconds, show confetti and play applause
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    showConfetti = true
                                    
                                    // Play applause sound
                                    if let applausePath = Bundle.main.path(forResource: "applause", ofType: "mp3") {
                                        do {
                                            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: applausePath))
                                            audioPlayer?.play()
                                        } catch {
                                            print("Could not play applause sound: \(error)")
                                        }
                                    }
                                }
                            } catch {
                                print("Could not play sound file: \(error)")
                            }
                        }
                    },
                    action: {
                        dismiss()
                    }
                )
            }
            
            // Move confetti to be a direct child of the main ZStack
            ConfettiAnimation(isVisible: $showConfetti)
                .allowsHitTesting(false)  // Make sure it doesn't interfere with buttons
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let topicString = String(describing: topic)
            let cardsDict = userLanguage == .english ? englishCards : hebrewCards
            
            // Check if we have a saved order for this topic
            if let savedOrder = scoreManager.getCardOrder(for: topic) {
                // Use the saved order
                shuffledCards = savedOrder
            } else {
                // First time - shuffle and save the order
                shuffledCards = (cardsDict[topicString] ?? []).shuffled()
                scoreManager.saveCardOrder(shuffledCards, for: topic)
            }
            
            completedCards = scoreManager.getCompletedCards(for: topic)
            currentCardIndex = scoreManager.getCardPosition(for: topic)
            generateAnswerOptions()
        }
    }
    
    private func generateAnswerOptions() {
        currentCardAttempts = 0  // Reset attempts for new card
        guard !shuffledCards.isEmpty, currentCardIndex < shuffledCards.count else {
            return
        }
        
        // Play sounds only for new (not completed) cards
        if !seenCards.contains(currentCardIndex) && !scoreManager.getCompletedCards(for: topic).contains(currentCardIndex) {
            seenCards.insert(currentCardIndex)
            // Play newCard sound
            if let path = Bundle.main.path(forResource: "newCard", ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.play()
                    
                    // Play element sound after newCard sound finishes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        playElementSound()
                    }
                } catch {
                    print("Could not play sound file: \(error)")
                }
            }
        } else {
            // Always play element sound for existing or completed cards
            playElementSound()
        }
        
        let currentCard = currentCards[currentCardIndex]
        var options = [(String, String)]()
        options.append(currentCard)
        
        let topicString = String(describing: topic)
        let allAnswers = (userLanguage == .english ? englishCards : hebrewCards)[topicString] ?? []
        let otherAnswers = allAnswers.filter { $0 != currentCard }.shuffled()
        
        if otherAnswers.count >= 2 {
            options.append(contentsOf: Array(otherAnswers.prefix(2)))
        }
        
        // Reset states when generating new options
        correctCards.remove(currentCardIndex)  // Remove from correctCards when revisiting
        canMoveToNext = false
        correctAnswer = nil
        wrongAnswer = nil
        
        // Handle completed cards
        if completedCards.contains(currentCardIndex) {
            correctAnswer = currentCard.1
            correctCards.insert(currentCardIndex)  // Add back to correctCards if it was completed
            canMoveToNext = true
            if let existingOptions = savedAnswerOptions[currentCardIndex] {
                answerOptions = existingOptions
                return
            }
        }
        
        options = options.shuffled()
        answerOptions = options
        savedAnswerOptions[currentCardIndex] = options
        
        // Reset visibility states and animate
        showAnswerButtons = [false, false, false]
        showSoundButtons = [false, false, false]
        
        // Animate answer buttons appearance
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation {
                    showAnswerButtons[i] = true
                }
            }
        }
        
        // Animate sound buttons appearance after answer buttons
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.2) {
                withAnimation {
                    showSoundButtons[i] = true
                }
            }
        }
    }
    
    private func checkAnswer(_ selectedAnswer: String) {
        isCorrect = selectedAnswer == currentCards[currentCardIndex].1
        currentCardAttempts += 1
        
        // Set feedback message based on language
        feedbackMessage = isCorrect 
            ? (userLanguage == .english ? "Correct!" : "נכון מאוד!")
            : (userLanguage == .english 
                ? "Wrong! Try again"
                : "בואו ננסה שוב...")
        
        if isCorrect {
            // Calculate points based on attempts
            let points = switch currentCardAttempts {
                case 1: 2    // First try: 2 points
                case 2: 1    // Second try: 1 point
                default: 0   // Third or more tries: 0 points
            }
            
            // Add points to the topic
            scoreManager.addPoints(points, for: topic)
            
            // Only add points if card wasn't previously completed
            if !scoreManager.getCompletedCards(for: topic).contains(currentCardIndex) {
                currentPoints = points
                scoreManager.correctAnswers += points
                if points > 0 {
                    showScoreAnimation = true
                }
            }
            
            // Simply show confetti
            showConfetti = true
            
            withAnimation(.easeInOut(duration: 0.5)) {
                correctCards.insert(currentCardIndex)
                correctAnswer = selectedAnswer
            }
            
            // Check if this was the last card
            if currentCardIndex == currentCards.count - 1 {
                scoreManager.markTopicAsCompleted(topic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCompletionPopup = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        feedbackMessage = nil
                        canMoveToNext = true
                    }
                }
            }
            
            // Play success sound
            if let path = Bundle.main.path(forResource: "scoreUp", ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.play()
                } catch {
                    print("Could not play sound file: \(error)")
                }
            }
        } else {
            wrongAnswer = selectedAnswer
            scoreManager.wrongAnswers += 1
            
            // Play negative sound
            if let path = Bundle.main.path(forResource: "negative", ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.play()
                } catch {
                    print("Could not play sound file: \(error)")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    wrongAnswer = nil
                    feedbackMessage = nil
                }
            }
        }
    }
    
    // New function to play Swedish sounds
    private func playSwedishSound(_ swedishWord: String) {
        if let path = Bundle.main.path(forResource: swedishWord, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not play sound file: \(error)")
            }
        } else {
            print("Could not find sound file: \(swedishWord).mp3")
        }
    }
    
    // Add this function to check for topic completion
    private func checkTopicCompletion() {
        if completedCards.count == currentCards.count {
            scoreManager.markTopicAsCompleted(topic)
            
            // Play CompletedTopic sound first
            let soundFile = userLanguage == .english ? "CompletedTopicEn" : "CompletedTopicHe"
            if let path = Bundle.main.path(forResource: soundFile, ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.play()
                } catch {
                    print("Could not play sound file: \(error)")
                }
            }
            
            // Show completion popup after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCompletionPopup = true
            }
        }
    }
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        .modifier(
            active: ScaleModifier(scale: 0),
            identity: ScaleModifier(scale: 1)
        ).combined(with: .opacity)
    }
    
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .leading)),
            removal: .opacity.combined(with: .move(edge: .trailing))
        )
    }
}

struct ScaleModifier: ViewModifier {
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content.scaleEffect(scale)
    }
}

