# Generate question_metadata.json
$questions = @()
$qNum = 1

# Chapter 1: Roots and Family Origins
$ch01Questions = @(
    @{ q="Where does your family come from?"; p="Establishes family roots and geographical origins"; m="factual"; t="warm"; d="medium"; tags=@("family","origins","homeland","roots"); people=@("parents","grandparents","ancestors"); places=@("hometown","village","country"); diff="easy"; pri="core" },
    @{ q="What were your parents' names and what were they like?"; p="Captures parental figures and their personalities"; m="descriptive"; t="affectionate"; d="medium"; tags=@("father","mother","parents","personality"); people=@("father","mother"); places=@(); diff="easy"; pri="core" },
    @{ q="Do you know much about your grandparents?"; p="Explores grandparent connections and family history depth"; m="narrative"; t="curious"; d="medium"; tags=@("grandparents","family tree","ancestors","heritage"); people=@("grandparents","grandfather","grandmother"); places=@(); diff="medium"; pri="core" },
    @{ q="What is the story of how your parents met?"; p="Captures the romantic origin story of the family"; m="narrative"; t="romantic"; d="long"; tags=@("parents","meeting","courtship","love story"); people=@("father","mother"); places=@(); diff="medium"; pri="core" },
    @{ q="What was life like in the town or village where you grew up?"; p="Paints a picture of the childhood environment"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("childhood","town","village","community","environment"); people=@(); places=@("childhood town","village","neighbourhood"); diff="easy"; pri="core" },
    @{ q="What did your parents do for work?"; p="Understanding family socioeconomic background"; m="factual"; t="respectful"; d="medium"; tags=@("parents","occupation","work","career","livelihood"); people=@("father","mother"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Were there any family stories passed down through generations?"; p="Captures oral tradition and family mythology"; m="narrative"; t="mysterious"; d="long"; tags=@("stories","legends","oral tradition","family lore"); people=@("ancestors","elders"); places=@(); diff="medium"; pri="core" },
    @{ q="What language or languages were spoken in your family?"; p="Explores cultural and linguistic heritage"; m="factual"; t="curious"; d="short"; tags=@("language","dialect","mother tongue","bilingual"); people=@(); places=@(); diff="easy"; pri="secondary" },
    @{ q="What was your family's religion or spiritual practice?"; p="Understanding spiritual and cultural foundations"; m="factual"; t="respectful"; d="medium"; tags=@("religion","faith","spiritual","church","temple","prayer"); people=@(); places=@("place of worship"); diff="easy"; pri="secondary" },
    @{ q="Did your family migrate or move from somewhere else?"; p="Captures migration stories and journeys"; m="narrative"; t="adventurous"; d="long"; tags=@("migration","moving","journey","relocation","displacement"); people=@("family"); places=@("original homeland","new home"); diff="medium"; pri="core" },
    @{ q="What were the values your family held most important?"; p="Identifies core family values and moral foundations"; m="reflective"; t="thoughtful"; d="medium"; tags=@("values","principles","morals","beliefs","ethics"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Who was the storyteller in your family?"; p="Identifies family narrative traditions"; m="descriptive"; t="affectionate"; d="medium"; tags=@("storyteller","narrator","family stories","oral history"); people=@("grandparent","aunt","uncle","elder"); places=@(); diff="easy"; pri="secondary" },
    @{ q="What hardships did your parents or grandparents face?"; p="Captures resilience and family strength stories"; m="narrative"; t="empathetic"; d="long"; tags=@("hardship","struggle","challenges","resilience","survival"); people=@("parents","grandparents"); places=@(); diff="hard"; pri="core" },
    @{ q="What traditions did your family keep?"; p="Documents family traditions and cultural practices"; m="descriptive"; t="warm"; d="medium"; tags=@("traditions","customs","rituals","cultural practices"); people=@("family"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Is there anything about your family history you wish you knew more about?"; p="Highlights gaps and mysteries in family knowledge"; m="reflective"; t="wistful"; d="medium"; tags=@("unknown","mystery","curiosity","family history","gaps"); people=@(); places=@(); diff="medium"; pri="secondary" }
)

foreach ($q in $ch01Questions) {
    $id = "ch01_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch01"; chapterNumber = 1; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 2: Birth and Early Childhood
$ch02Questions = @(
    @{ q="When and where were you born?"; p="Establishes birth details and setting"; m="factual"; t="warm"; d="short"; tags=@("birth","born","date of birth","birthplace"); people=@(); places=@("hospital","birthplace","home"); diff="easy"; pri="core" },
    @{ q="What was the world like when you were born?"; p="Sets historical context for the birth"; m="descriptive"; t="curious"; d="medium"; tags=@("world","era","time period","historical context"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the story of the day you were born?"; p="Captures birth narrative and family stories"; m="narrative"; t="excited"; d="long"; tags=@("birth","story","family","day","born"); people=@("mother","father","family"); places=@("hospital","birthplace"); diff="medium"; pri="core" },
    @{ q="What was your name given at birth and did it have a meaning?"; p="Explores naming traditions and significance"; m="factual"; t="curious"; d="medium"; tags=@("name","meaning","naming","baptism"); people=@("parents","grandparents"); places=@(); diff="easy"; pri="core" },
    @{ q="How many siblings did you have and where did you fit in?"; p="Establishes family structure and birth order"; m="factual"; t="warm"; d="medium"; tags=@("siblings","brothers","sisters","birth order","family size"); people=@("brothers","sisters","siblings"); places=@(); diff="easy"; pri="core" },
    @{ q="What is your very first memory?"; p="Captures earliest conscious memory"; m="sensory"; t="nostalgic"; d="medium"; tags=@("first memory","earliest memory","childhood","remember"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What were you like as a baby and toddler?"; p="Captures early personality and development"; m="descriptive"; t="affectionate"; d="medium"; tags=@("baby","toddler","personality","development","character"); people=@("parents","siblings"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was your home like when you were very small?"; p="Paints a picture of early childhood home"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("home","house","childhood","room","environment"); people=@(); places=@("childhood home","room"); diff="easy"; pri="secondary" },
    @{ q="Who took care of you when you were young?"; p="Identifies primary caregivers and early relationships"; m="descriptive"; t="warm"; d="medium"; tags=@("caregiver","parent","grandparent","nanny","childcare"); people=@("mother","father","grandmother","nanny"); places=@(); diff="easy"; pri="core" },
    @{ q="What were your favourite foods as a child?"; p="Captures early food memories and preferences"; m="sensory"; t="playful"; d="short"; tags=@("food","favourite","eating","meals","childhood"); people=@(); places=@(); diff="easy"; pri="secondary" },
    @{ q="What toys or games did you love most?"; p="Captures childhood play and interests"; m="descriptive"; t="playful"; d="short"; tags=@("toys","games","play","childhood","fun"); people=@(); places=@(); diff="easy"; pri="secondary" },
    @{ q="Were you a happy child? What made you smile?"; p="Explores early emotional landscape"; m="reflective"; t="warm"; d="medium"; tags=@("happy","smile","joy","childhood","emotions"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is a funny or memorable thing that happened when you were little?"; p="Captures amusing childhood anecdotes"; m="narrative"; t="humorous"; d="medium"; tags=@("funny","memorable","childhood","story","incident"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What were you afraid of as a child?"; p="Explores early fears and anxieties"; m="reflective"; t="empathetic"; d="medium"; tags=@("fear","afraid","scared","nightmare","childhood"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is one thing from your early childhood you never want to forget?"; p="Identifies most treasured early memory"; m="reflective"; t="tender"; d="medium"; tags=@("cherished","memory","forget","important","precious"); people=@(); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch02Questions) {
    $id = "ch02_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch02"; chapterNumber = 2; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 3: Home and Neighbourhood
$ch03Questions = @(
    @{ q="What does your childhood home look like in your memory?"; p="Creates a vivid mental picture of the childhood home"; m="sensory"; t="nostalgic"; d="medium"; tags=@("home","house","childhood","appearance","rooms"); people=@(); places=@("childhood home","rooms","garden"); diff="easy"; pri="core" },
    @{ q="Describe the neighbourhood where you grew up."; p="Paints a picture of the surrounding community"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("neighbourhood","community","street","area","childhood"); people=@(); places=@("street","neighbourhood","community"); diff="easy"; pri="core" },
    @{ q="Who were your neighbours? Did you know them well?"; p="Explores community relationships and social bonds"; m="descriptive"; t="warm"; d="medium"; tags=@("neighbours","community","friends","relationships"); people=@("neighbours","friends"); places=@("neighbourhood"); diff="easy"; pri="secondary" },
    @{ q="What was your favourite room in the house and why?"; p="Identifies personal space and comfort zones"; m="descriptive"; t="intimate"; d="medium"; tags=@("room","favourite","bedroom","kitchen","play"); people=@(); places=@("favourite room"); diff="easy"; pri="secondary" },
    @{ q="Where did you play as a child?"; p="Maps out childhood play spaces and adventures"; m="descriptive"; t="playful"; d="medium"; tags=@("play","outdoors","playground","garden","park"); people=@(); places=@("garden","playground","park","street"); diff="easy"; pri="core" },
    @{ q="What sounds, smells, or sights do you associate with growing up?"; p="Captures sensory memories of childhood"; m="sensory"; t="nostalgic"; d="medium"; tags=@("sounds","smells","sights","sensory","memories"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Did you have your own bedroom or did you share?"; p="Explores living arrangements and personal space"; m="factual"; t="casual"; d="short"; tags=@("bedroom","sharing","room","personal space"); people=@("siblings"); places=@("bedroom"); diff="easy"; pri="secondary" },
    @{ q="Was there a garden or outdoor space? What was it like?"; p="Explores outdoor childhood spaces"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("garden","outdoor","trees","nature","yard"); people=@(); places=@("garden","yard","outdoor space"); diff="easy"; pri="secondary" },
    @{ q="What was the best thing about your neighbourhood?"; p="Identifies positive aspects of childhood environment"; m="reflective"; t="appreciative"; d="medium"; tags=@("neighbourhood","best","community","positive"); people=@(); places=@("neighbourhood"); diff="easy"; pri="secondary" },
    @{ q="What was the most exciting place near your home?"; p="Identifies adventure spots in childhood"; m="descriptive"; t="excited"; d="medium"; tags=@("exciting","adventure","exploration","favourite place"); people=@(); places=@("park","shop","river","woods"); diff="easy"; pri="secondary" },
    @{ q="Did anything frightening ever happen in your neighbourhood?"; p="Captures challenging neighbourhood experiences"; m="narrative"; t="empathetic"; d="medium"; tags=@("frightening","scary","incident","danger","neighbourhood"); people=@(); places=@("neighbourhood"); diff="medium"; pri="secondary" },
    @{ q="What shops or businesses were nearby?"; p="Maps out the childhood commercial landscape"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("shops","store","business","local","market"); people=@(); places=@("shop","market","street"); diff="easy"; pri="secondary" },
    @{ q="Did you ever move house as a child? How did that feel?"; p="Explores transitions and sense of belonging"; m="narrative"; t="reflective"; d="medium"; tags=@("moving","new home","leaving","change","transition"); people=@("family"); places=@("old home","new home"); diff="medium"; pri="secondary" },
    @{ q="If you could go back and visit one place from your childhood, where would it be?"; p="Identifies most meaningful childhood places"; m="reflective"; t="wistful"; d="medium"; tags=@("visit","childhood","place","memory","return"); people=@(); places=@("childhood place"); diff="medium"; pri="core" },
    @{ q="How did your childhood home shape the person you became?"; p="Connects environment to personal development"; m="reflective"; t="thoughtful"; d="medium"; tags=@("home","shaped","person","development","influence"); people=@(); places=@("childhood home"); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch03Questions) {
    $id = "ch03_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch03"; chapterNumber = 3; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 4: School Days
$ch04Questions = @(
    @{ q="How old were you when you started school?"; p="Establishes educational timeline"; m="factual"; t="casual"; d="short"; tags=@("school","age","started","began","education"); people=@(); places=@("school"); diff="easy"; pri="core" },
    @{ q="What was your first school like?"; p="Paints a picture of the educational setting"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("school","first school","building","classroom","environment"); people=@(); places=@("school","classroom"); diff="easy"; pri="core" },
    @{ q="How did you feel on your first day of school?"; p="Captures emotional experience of starting education"; m="emotional"; t="empathetic"; d="medium"; tags=@("first day","feelings","nervous","excited","scared"); people=@(); places=@("school"); diff="easy"; pri="core" },
    @{ q="Can you remember any of your teachers?"; p="Recalls influential educators"; m="descriptive"; t="respectful"; d="medium"; tags=@("teacher","teachers","educator","school","class"); people=@("teachers"); places=@("school"); diff="easy"; pri="core" },
    @{ q="Were you a good student? What were you like in class?"; p="Explores academic personality and learning style"; m="reflective"; t="honest"; d="medium"; tags=@("student","class","academic","behaviour","learning"); people=@("teachers","classmates"); places=@("school","classroom"); diff="medium"; pri="secondary" },
    @{ q="What subjects did you enjoy most? Which ones were hardest?"; p="Identifies academic strengths and interests"; m="reflective"; t="thoughtful"; d="medium"; tags=@("subjects","enjoy","difficult","academic","learning"); people=@(); places=@("school"); diff="easy"; pri="secondary" },
    @{ q="Did you have a favourite teacher? What made them special?"; p="Identifies mentors and educational influences"; m="descriptive"; t="warm"; d="medium"; tags=@("favourite teacher","special","mentor","influence"); people=@("favourite teacher"); places=@("school"); diff="medium"; pri="core" },
    @{ q="What was school lunch like? Did you have a favourite meal?"; p="Captures sensory school memories"; m="sensory"; t="nostalgic"; d="short"; tags=@("lunch","food","canteen","meal","school"); people=@(); places=@("school canteen","dining hall"); diff="easy"; pri="secondary" },
    @{ q="Did you play any sports at school?"; p="Explores athletic experiences and interests"; m="descriptive"; t="energetic"; d="medium"; tags=@("sports","games","athletics","PE","physical education"); people=@(); places=@("playing field","gymnasium"); diff="easy"; pri="secondary" },
    @{ q="What games did you play during break time?"; p="Captures playground culture and social play"; m="descriptive"; t="playful"; d="medium"; tags=@("games","break time","recess","playground","fun"); people=@("friends","classmates"); places=@("playground"); diff="easy"; pri="secondary" },
    @{ q="Did you ever get into trouble at school?"; p="Captures memorable disciplinary or mischievous moments"; m="narrative"; t="humorous"; d="medium"; tags=@("trouble","mischief","naughty","punishment","school"); people=@("teachers","classmates"); places=@("school"); diff="medium"; pri="secondary" },
    @{ q="What was your favourite memory from school?"; p="Identifies most treasured school experience"; m="narrative"; t="warm"; d="medium"; tags=@("favourite","memory","school","best","moment"); people=@(); places=@("school"); diff="medium"; pri="core" },
    @{ q="Did school feel safe and welcoming for you?"; p="Explores emotional safety in educational setting"; m="reflective"; t="empathetic"; d="medium"; tags=@("safe","welcome","belonging","school","environment"); people=@(); places=@("school"); diff="medium"; pri="secondary" },
    @{ q="How did your parents feel about your education?"; p="Explores family attitudes towards learning"; m="descriptive"; t="thoughtful"; d="medium"; tags=@("parents","education","school","values","expectations"); people=@("parents","mother","father"); places=@("school"); diff="medium"; pri="secondary" },
    @{ q="What lessons from school have stayed with you all your life?"; p="Connects education to lifelong impact"; m="reflective"; t="thoughtful"; d="medium"; tags=@("lessons","life","education","impact","wisdom"); people=@(); places=@("school"); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch04Questions) {
    $id = "ch04_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch04"; chapterNumber = 4; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 5: Friends and Growing Up
$ch05Questions = @(
    @{ q="Who were your closest friends growing up?"; p="Identifies childhood friendships and bonds"; m="descriptive"; t="warm"; d="medium"; tags=@("friends","childhood","closest","bonds","companions"); people=@("friends","childhood friends"); places=@(); diff="easy"; pri="core" },
    @{ q="How did you meet your best friend?"; p="Captures friendship origin stories"; m="narrative"; t="warm"; d="medium"; tags=@("best friend","meeting","how we met","friendship"); people=@("best friend"); places=@("school","neighbourhood"); diff="easy"; pri="core" },
    @{ q="What did you and your friends do for fun?"; p="Captures childhood activities and shared adventures"; m="narrative"; t="playful"; d="medium"; tags=@("fun","activities","games","adventures","play"); people=@("friends"); places=@(); diff="easy"; pri="core" },
    @{ q="Were there any secrets you shared with your friends?"; p="Explores intimacy and trust in childhood friendships"; m="reflective"; t="intimate"; d="medium"; tags=@("secrets","trust","sharing","close","intimate"); people=@("friends"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you ever have a falling out with a friend? What happened?"; p="Explores conflict and resolution in friendships"; m="narrative"; t="reflective"; d="medium"; tags=@("falling out","argument","fight","conflict","friendship"); people=@("friend"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Were you part of any groups or clubs?"; p="Explores group memberships and social identity"; m="descriptive"; t="proud"; d="medium"; tags=@("groups","clubs","membership","team","community"); people=@(); places=@("club","community centre"); diff="easy"; pri="secondary" },
    @{ q="Who was your first crush? Do you remember how it felt?"; p="Captures early romantic feelings"; m="emotional"; t="shy"; d="medium"; tags=@("crush","romance","feelings","first love","childhood"); people=@("crush"); places=@("school"); diff="medium"; pri="secondary" },
    @{ q="What did your friends think you would become when you grew up?"; p="Explores youthful perceptions and aspirations"; m="narrative"; t="amused"; d="medium"; tags=@("future","grown up","dreams","friends","predictions"); people=@("friends"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did any of your childhood friendships last into adulthood?"; p="Explores lasting friendship bonds"; m="reflective"; t="appreciative"; d="medium"; tags=@("lifelong","friends","lasting","adulthood","reunion"); people=@("old friends"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you have a friend who was very different from you? What drew you together?"; p="Explores diversity in friendships"; m="descriptive"; t="curious"; d="medium"; tags=@("different","diverse","friendship","connection","unique"); people=@("friend"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Were there any adults outside your family who were important to you?"; p="Identifies other adult influences and mentors"; m="descriptive"; t="grateful"; d="medium"; tags=@("adult","mentor","influence","important","guidance"); people=@("teacher","coach","neighbour","relative"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you ever feel left out or excluded by other children?"; p="Explores social challenges and resilience"; m="emotional"; t="empathetic"; d="medium"; tags=@("left out","excluded","lonely","bullying","social"); people=@("classmates","children"); places=@("school"); diff="hard"; pri="secondary" },
    @{ q="What made you laugh as a child?"; p="Captures childhood joy and humour"; m="descriptive"; t="playful"; d="medium"; tags=@("laugh","humour","funny","joy","happiness"); people=@("friends","family"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Who taught you how to be a good friend?"; p="Explores friendship values and learning"; m="reflective"; t="thoughtful"; d="medium"; tags=@("friendship","learned","values","taught","being a friend"); people=@("friends","parents"); places=@(); diff="medium"; pri="secondary" },
    @{ q="If you could write a letter to one of your childhood friends, what would you say?"; p="Captures feelings about formative friendships"; m="reflective"; t="tender"; d="medium"; tags=@("letter","childhood friend","message","feelings","reconnect"); people=@("childhood friend"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch05Questions) {
    $id = "ch05_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch05"; chapterNumber = 5; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 6: Dreams and Youth
$ch06Questions = @(
    @{ q="What did you dream of becoming when you were young?"; p="Captures childhood aspirations and dreams"; m="reflective"; t="hopeful"; d="medium"; tags=@("dreams","future","career","aspirations","young"); people=@(); places=@(); diff="easy"; pri="core" },
    @{ q="What were your teenage years like?"; p="Explores adolescent experiences"; m="narrative"; t="reflective"; d="long"; tags=@("teenage","adolescence","youth","growing up"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What music did you love as a young person?"; p="Captures musical tastes and cultural influences"; m="descriptive"; t="enthusiastic"; d="medium"; tags=@("music","songs","bands","concerts","youth"); people=@(); places=@("concert","dance"); diff="easy"; pri="secondary" },
    @{ q="What were the most popular things among your friends?"; p="Explores youth culture and social trends"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("popular","trends","fashion","culture","friends"); people=@("friends"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Did you rebel against your parents as a teenager?"; p="Explores adolescent independence and family dynamics"; m="narrative"; t="honest"; d="medium"; tags=@("rebellion","teenage","parents","conflict","independence"); people=@("parents"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What books, films or shows influenced you as a young person?"; p="Explores cultural influences on worldview"; m="descriptive"; t="thoughtful"; d="medium"; tags=@("books","films","shows","influenced","culture"); people=@(); places=@("cinema","library"); diff="medium"; pri="secondary" },
    @{ q="What were your greatest fears as a teenager?"; p="Explores adolescent anxieties"; m="reflective"; t="empathetic"; d="medium"; tags=@("fears","anxiety","teenage","worries","growing up"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What did you think adulthood would be like?"; p="Contrasts youthful expectations with reality"; m="reflective"; t="amused"; d="medium"; tags=@("adulthood","expectations","future","grown up","thought"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Was there a moment when you felt like you were no longer a child?"; p="Identifies coming-of-age moment"; m="narrative"; t="reflective"; d="medium"; tags=@("growing up","moment","adult","childhood","transition"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What was the biggest change in your life during your youth?"; p="Identifies transformative youth experiences"; m="narrative"; t="reflective"; d="medium"; tags=@("change","youth","transition","transformation","growth"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you have a role model during your teenage years?"; p="Identifies youth influences and aspirations"; m="descriptive"; t="respectful"; d="medium"; tags=@("role model","hero","influence","admired","youth"); people=@("role model","hero"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was your first experience of heartbreak?"; p="Captures emotional milestones and resilience"; m="emotional"; t="tender"; d="medium"; tags=@("heartbreak","love","loss","emotional","youth"); people=@(); places=@(); diff="hard"; pri="secondary" },
    @{ q="What freedoms did you enjoy as a teenager?"; p="Explores independence and growing autonomy"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("freedom","independence","teenage","autonomy","adventure"); people=@(); places=@(); diff="easy"; pri="secondary" },
    @{ q="What advice would you give to today's teenagers?"; p="Connects personal experience to generational wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("advice","teenagers","wisdom","generations","learning"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the happiest memory from your youth?"; p="Captures peak joy from formative years"; m="narrative"; t="joyful"; d="medium"; tags=@("happiest","memory","youth","joy","peak"); people=@(); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch06Questions) {
    $id = "ch06_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch06"; chapterNumber = 6; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 7: Education and Learning
$ch07Questions = @(
    @{ q="What was the most important thing you learned outside of school?"; p="Explores informal education and life learning"; m="reflective"; t="thoughtful"; d="medium"; tags=@("learned","outside school","life lessons","education","growth"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Did you pursue any further education after school?"; p="Documents educational journey beyond school"; m="factual"; t="proud"; d="medium"; tags=@("further education","college","university","training","diploma"); people=@(); places=@("college","university"); diff="easy"; pri="core" },
    @{ q="Who taught you the skills that earned you a living?"; p="Identifies mentors and learning paths for career"; m="descriptive"; t="grateful"; d="medium"; tags=@("skills","taught","mentor","learning","career"); people=@("mentor","teacher","trainer"); places=@("workplace","training centre"); diff="medium"; pri="secondary" },
    @{ q="What book or piece of knowledge changed your thinking?"; p="Captures transformative learning moments"; m="reflective"; t="thoughtful"; d="medium"; tags=@("book","knowledge","changed thinking","insight","realization"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you teach yourself anything? How did you learn it?"; p="Explores self-directed learning and initiative"; m="narrative"; t="proud"; d="medium"; tags=@("self-taught","learned","initiative","skill","independent"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was a mistake that taught you something valuable?"; p="Explores learning through failure"; m="narrative"; t="humble"; d="medium"; tags=@("mistake","lesson","failure","learning","growth"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What skill are you most proud of learning?"; p="Identifies proudest learning achievement"; m="reflective"; t="proud"; d="medium"; tags=@("skill","proud","learning","achievement","mastery"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Did anyone ever believe in you before you believed in yourself?"; p="Captures mentorship and encouragement moments"; m="emotional"; t="grateful"; d="medium"; tags=@("believe","mentor","encouragement","support","confidence"); people=@("mentor","teacher","friend"); places=@(); diff="medium"; pri="core" },
    @{ q="What hobby or interest did you pick up that surprised you?"; p="Explores unexpected learning and growth"; m="narrative"; t="amused"; d="medium"; tags=@("hobby","interest","surprise","unexpected","learning"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What did your parents teach you without words?"; p="Explores implicit learning through observation"; m="reflective"; t="thoughtful"; d="medium"; tags=@("taught","parents","example","actions","values"); people=@("parents","father","mother"); places=@(); diff="medium"; pri="core" },
    @{ q="How did the world change during your lifetime and how did you keep up?"; p="Explores adaptation and lifelong learning"; m="narrative"; t="reflective"; d="long"; tags=@("change","adaptation","technology","modern","learning"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What would you still like to learn if you had the time?"; p="Explores unfulfilled learning desires"; m="reflective"; t="wistful"; d="medium"; tags=@("learn","desire","wish","time","interest"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the wisest thing anyone ever said to you?"; p="Captures influential advice and wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("wisdom","advice","wise","saying","words"); people=@("mentor","parent","friend"); places=@(); diff="medium"; pri="core" },
    @{ q="How has learning kept you young at heart?"; p="Connects learning to vitality and purpose"; m="reflective"; t="appreciative"; d="medium"; tags=@("learning","young","vitality","purpose","energy"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What knowledge would you pass on to your grandchildren?"; p="Identifies most valuable life knowledge for legacy"; m="reflective"; t="purposeful"; d="medium"; tags=@("pass on","grandchildren","knowledge","legacy","wisdom"); people=@("grandchildren"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch07Questions) {
    $id = "ch07_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch07"; chapterNumber = 7; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 8: First Job and Career
$ch08Questions = @(
    @{ q="What was your very first job?"; p="Captures career beginnings"; m="factual"; t="nostalgic"; d="medium"; tags=@("first job","work","career","employment","beginning"); people=@(); places=@("workplace"); diff="easy"; pri="core" },
    @{ q="How old were you when you started working?"; p="Establishes work timeline"; m="factual"; t="casual"; d="short"; tags=@("age","started working","began","youth","work"); people=@(); places=@(); diff="easy"; pri="core" },
    @{ q="What did your first day at work feel like?"; p="Captures the emotion of starting work"; m="emotional"; t="nervous"; d="medium"; tags=@("first day","work","nervous","excited","job"); people=@(); places=@("workplace"); diff="easy"; pri="secondary" },
    @{ q="What was the most satisfying job you ever had?"; p="Identifies peak career satisfaction"; m="reflective"; t="proud"; d="medium"; tags=@("satisfying","best job","career","fulfilling","work"); people=@(); places=@("workplace"); diff="medium"; pri="core" },
    @{ q="What was the hardest job you ever had?"; p="Explores challenging work experiences"; m="narrative"; t="reflective"; d="medium"; tags=@("hardest","difficult","challenging","job","work"); people=@(); places=@("workplace"); diff="medium"; pri="secondary" },
    @{ q="Did you have a boss or colleague who made a big impression on you?"; p="Identifies workplace influences and relationships"; m="descriptive"; t="respectful"; d="medium"; tags=@("boss","colleague","impression","workplace","influence"); people=@("boss","colleague","co-worker"); places=@("workplace"); diff="medium"; pri="secondary" },
    @{ q="What did you enjoy most about your work?"; p="Identifies career satisfaction drivers"; m="reflective"; t="appreciative"; d="medium"; tags=@("enjoy","work","career","satisfaction","fulfillment"); people=@(); places=@("workplace"); diff="medium"; pri="secondary" },
    @{ q="What was a typical workday like for you?"; p="Paints a picture of daily work life"; m="descriptive"; t="routine"; d="medium"; tags=@("typical day","workday","routine","daily","work"); people=@(); places=@("workplace"); diff="easy"; pri="secondary" },
    @{ q="Did work take you away from your family? How did that feel?"; p="Explores work-family balance challenges"; m="emotional"; t="empathetic"; d="medium"; tags=@("family","work balance","absence","sacrifice","travel"); people=@("family","spouse","children"); places=@(); diff="hard"; pri="secondary" },
    @{ q="Were there any funny moments at work you remember?"; p="Captures workplace humour and memorable incidents"; m="narrative"; t="humorous"; d="medium"; tags=@("funny","workplace","humour","incident","story"); people=@("colleagues"); places=@("workplace"); diff="medium"; pri="secondary" },
    @{ q="How did work shape who you are?"; p="Connects career to personal identity"; m="reflective"; t="thoughtful"; d="medium"; tags=@("work","shaped","identity","person","character"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What are you most proud of in your working life?"; p="Identifies peak professional achievement"; m="reflective"; t="proud"; d="medium"; tags=@("proud","achievement","career","pride","success"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Did you experience any unfairness or discrimination at work?"; p="Captures workplace challenges and injustice"; m="narrative"; t="empathetic"; d="medium"; tags=@("unfairness","discrimination","workplace","challenge","justice"); people=@(); places=@("workplace"); diff="hard"; pri="secondary" },
    @{ q="What advice would you give someone starting their career today?"; p="Extracts career wisdom from experience"; m="reflective"; t="wise"; d="medium"; tags=@("advice","career","wisdom","starting","beginning"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="When did you know it was time to retire?"; p="Explores retirement decision and feelings"; m="reflective"; t="peaceful"; d="medium"; tags=@("retirement","retired","leaving work","decision","end"); people=@(); places=@(); diff="medium"; pri="secondary" }
)

$qNum = 1
foreach ($q in $ch08Questions) {
    $id = "ch08_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch08"; chapterNumber = 8; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 9: Love and Relationships
$ch09Questions = @(
    @{ q="How old were you when you fell in love for the first time?"; p="Establishes romantic timeline"; m="factual"; t="warm"; d="short"; tags=@("love","first time","age","romance","relationship"); people=@(); places=@(); diff="easy"; pri="core" },
    @{ q="What was the story of how you met your life partner?"; p="Captures the origin story of the main relationship"; m="narrative"; t="romantic"; d="long"; tags=@("met","partner","meeting","story","love"); people=@("partner","spouse"); places=@(); diff="medium"; pri="core" },
    @{ q="What was it about them that caught your eye?"; p="Identifies what attracted them to their partner"; m="descriptive"; t="affectionate"; d="medium"; tags=@("attraction","caught eye","love","first impression","partner"); people=@("partner"); places=@(); diff="medium"; pri="core" },
    @{ q="How did you know they were the one?"; p="Captures moment of certainty in love"; m="emotional"; t="certain"; d="medium"; tags=@("knew","the one","certainty","love","partner"); people=@("partner"); places=@(); diff="medium"; pri="core" },
    @{ q="Describe your first date together."; p="Captures the beginning of romantic story"; m="narrative"; t="excited"; d="medium"; tags=@("first date","date","romance","beginning","together"); people=@("partner"); places=@("date location"); diff="medium"; pri="secondary" },
    @{ q="Were there any obstacles to your relationship?"; p="Explores challenges overcome in love"; m="narrative"; t="reflective"; d="medium"; tags=@("obstacles","challenges","difficulties","relationship","overcome"); people=@("partner","family"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the most romantic thing they ever did for you?"; p="Captures memorable romantic gestures"; m="narrative"; t="tender"; d="medium"; tags=@("romantic","gesture","special","love","memory"); people=@("partner"); places=@(); diff="medium"; pri="core" },
    @{ q="What was the hardest part about being in love?"; p="Explores challenges and sacrifices in love"; m="reflective"; t="honest"; d="medium"; tags=@("hardest","love","challenge","sacrifice","difficulty"); people=@("partner"); places=@(); diff="medium"; pri="secondary" },
    @{ q="How did your parents feel about your relationship?"; p="Explores family dynamics in romantic relationships"; m="descriptive"; t="thoughtful"; d="medium"; tags=@("parents","relationship","approval","family","feelings"); people=@("parents","partner"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you ever have doubts about your relationship?"; p="Explores vulnerability and resolution in love"; m="reflective"; t="honest"; d="medium"; tags=@("doubts","uncertainty","relationship","worries","resolve"); people=@("partner"); places=@(); diff="hard"; pri="secondary" },
    @{ q="What do you love most about them now?"; p="Explores enduring love and appreciation"; m="reflective"; t="loving"; d="medium"; tags=@("love","most","now","appreciate","partner"); people=@("partner"); places=@(); diff="medium"; pri="core" },
    @{ q="How has love changed you as a person?"; p="Explores personal growth through love"; m="reflective"; t="thoughtful"; d="medium"; tags=@("love","changed","growth","person","transformation"); people=@("partner"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is your secret to a long and happy relationship?"; p="Extracts relationship wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("secret","relationship","happy","long","wisdom"); people=@("partner"); places=@(); diff="medium"; pri="core" },
    @{ q="How did you keep the spark alive over the years?"; p="Explores maintaining love over time"; m="reflective"; t="warm"; d="medium"; tags=@("spark","romance","alive","relationship","love"); people=@("partner"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What does love mean to you now, looking back?"; p="Reflects on evolving understanding of love"; m="reflective"; t="wise"; d="medium"; tags=@("love","meaning","now","looking back","wisdom"); people=@(); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch09Questions) {
    $id = "ch09_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch09"; chapterNumber = 9; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 10: Marriage and Partnership
$ch10Questions = @(
    @{ q="How did the proposal happen?"; p="Captures the proposal story"; m="narrative"; t="excited"; d="long"; tags=@("proposal","engagement","asked","marriage","question"); people=@("partner","spouse"); places=@(); diff="medium"; pri="core" },
    @{ q="What was your wedding day like?"; p="Captures the wedding celebration"; m="narrative"; t="joyful"; d="long"; tags=@("wedding","day","celebration","marriage","ceremony"); people=@("spouse","family","friends"); places=@("wedding venue","church","registry office"); diff="medium"; pri="core" },
    @{ q="What were you feeling as you walked down the aisle?"; p="Captures raw emotion of the wedding moment"; m="emotional"; t="emotional"; d="medium"; tags=@("walking","aisle","feelings","nervous","excited"); people=@("spouse"); places=@("ceremony venue"); diff="medium"; pri="core" },
    @{ q="Who came to your wedding and what was the best part?"; p="Captures guests and highlights of the day"; m="narrative"; t="happy"; d="medium"; tags=@("wedding","guests","best part","celebration","family"); people=@("family","friends","guests"); places=@("wedding venue"); diff="easy"; pri="secondary" },
    @{ q="How did married life change things?"; p="Explores transition from dating to married life"; m="reflective"; t="thoughtful"; d="medium"; tags=@("married life","change","transition","marriage","together"); people=@("spouse"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was the first home you shared together like?"; p="Captures early married life setting"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("first home","together","married","flat","house"); people=@("spouse"); places=@("first home"); diff="easy"; pri="secondary" },
    @{ q="What was your biggest argument and how did you resolve it?"; p="Explores conflict resolution and relationship strength"; m="narrative"; t="honest"; d="medium"; tags=@("argument","conflict","resolved","marriage","disagreement"); people=@("spouse"); places=@(); diff="hard"; pri="secondary" },
    @{ q="What traditions did you and your partner create together?"; p="Documents couple traditions and rituals"; m="descriptive"; t="warm"; d="medium"; tags=@("traditions","together","couple","rituals","customs"); people=@("spouse"); places=@(); diff="medium"; pri="secondary" },
    @{ q="How did you divide responsibilities at home?"; p="Explores partnership dynamics and household roles"; m="descriptive"; t="practical"; d="medium"; tags=@("division","responsibilities","home","housework","partnership"); people=@("spouse"); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="Did you have a favourite place you loved to go together?"; p="Captures shared favourite places and experiences"; m="descriptive"; t="fond"; d="medium"; tags=@("favourite place","together","couple","memories","special"); people=@("spouse"); places=@("favourite place"); diff="easy"; pri="secondary" },
    @{ q="What has been the greatest joy of your marriage?"; p="Identifies peak marital happiness"; m="reflective"; t="joyful"; d="medium"; tags=@("greatest joy","marriage","happiness","best","love"); people=@("spouse"); places=@(); diff="medium"; pri="core" },
    @{ q="What is a small everyday moment with your partner that you treasure?"; p="Captures quiet, everyday love"; m="descriptive"; t="tender"; d="medium"; tags=@("small","everyday","moment","treasure","love"); people=@("spouse"); places=@(); diff="medium"; pri="core" },
    @{ q="How did you support each other through difficult times?"; p="Explores mutual support and resilience in marriage"; m="narrative"; t="grateful"; d="medium"; tags=@("support","difficult","together","resilience","marriage"); people=@("spouse"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What would you tell young couples starting out today?"; p="Extracts marriage wisdom for future generations"; m="reflective"; t="wise"; d="medium"; tags=@("advice","young couples","marriage","wisdom","starting out"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="If you could relive one day of your married life, which would it be?"; p="Identifies most cherished marital moment"; m="reflective"; t="nostalgic"; d="medium"; tags=@("relive","day","married life","favourite","memory"); people=@("spouse"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch10Questions) {
    $id = "ch10_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch10"; chapterNumber = 10; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 11: Parenthood
$ch11Questions = @(
    @{ q="How did you find out you were going to be a parent?"; p="Captures the moment of learning about parenthood"; m="narrative"; t="excited"; d="medium"; tags=@("pregnancy","expecting","parenthood","discovery","news"); people=@("spouse","partner"); places=@(); diff="medium"; pri="core" },
    @{ q="What were you feeling in the months before your first child was born?"; p="Captures anticipation and emotions before parenthood"; m="emotional"; t="nervous"; d="medium"; tags=@("pregnancy","anticipation","nervous","excited","expecting"); people=@("spouse","partner"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Tell me about the day your first child was born."; p="Captures the birth story of the first child"; m="narrative"; t="emotional"; d="long"; tags=@("birth","first child","baby","born","delivery"); people=@("child","spouse"); places=@("hospital","home"); diff="medium"; pri="core" },
    @{ q="What was it like to hold your baby for the first time?"; p="Captures the emotional weight of first holding a child"; m="emotional"; t="tender"; d="medium"; tags=@("hold","baby","first time","emotional","love"); people=@("child"); places=@("hospital"); diff="medium"; pri="core" },
    @{ q="How did becoming a parent change you?"; p="Explores personal transformation through parenthood"; m="reflective"; t="thoughtful"; d="medium"; tags=@("parent","change","transformation","growth","person"); people=@("children"); places=@(); diff="medium"; pri="core" },
    @{ q="What was the hardest part about being a new parent?"; p="Explores early parenting challenges"; m="reflective"; t="honest"; d="medium"; tags=@("hardest","new parent","challenge","difficult","baby"); people=@("child"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was the most joyful moment with your children?"; p="Identifies peak parenting happiness"; m="narrative"; t="joyful"; d="medium"; tags=@("joyful","moment","children","happiness","best"); people=@("children"); places=@(); diff="medium"; pri="core" },
    @{ q="Did you name your children after someone special?"; p="Explores naming traditions and family connections"; m="factual"; t="warm"; d="short"; tags=@("naming","children","names","special","honour"); people=@("children","honoured person"); places=@(); diff="easy"; pri="secondary" },
    @{ q="What was each of your children like as babies?"; p="Captures early personality of each child"; m="descriptive"; t="affectionate"; d="medium"; tags=@("children","babies","personality","character","unique"); people=@("children"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What traditions did you start with your children?"; p="Documents family traditions created for children"; m="descriptive"; t="warm"; d="medium"; tags=@("traditions","children","family","rituals","customs"); people=@("children"); places=@(); diff="medium"; pri="secondary" },
    @{ q="How did your own parents help with raising your children?"; p="Explores grandparent involvement and family support"; m="descriptive"; t="grateful"; d="medium"; tags=@("grandparents","help","raising","support","family"); people=@("parents","grandparents","children"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What did you worry about most as a parent?"; p="Explores parental anxieties and concerns"; m="reflective"; t="honest"; d="medium"; tags=@("worry","anxiety","parent","concern","fear"); people=@("children"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What are you most proud of as a parent?"; p="Identifies parenting achievements and pride"; m="reflective"; t="proud"; d="medium"; tags=@("proud","parent","achievement","children","pride"); people=@("children"); places=@(); diff="medium"; pri="core" },
    @{ q="What would you do differently if you could raise your children again?"; p="Explores honest reflection on parenting"; m="reflective"; t="honest"; d="medium"; tags=@("differently","regret","parenting","reflection","lessons"); people=@("children"); places=@(); diff="hard"; pri="secondary" },
    @{ q="What message do you want your children to carry from you?"; p="Captures the core message for children"; m="reflective"; t="purposeful"; d="medium"; tags=@("message","children","carry","wisdom","values"); people=@("children"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch11Questions) {
    $id = "ch11_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch11"; chapterNumber = 11; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 12: Home and Family Life
$ch12Questions = @(
    @{ q="What does home mean to you?"; p="Explores emotional meaning of home"; m="reflective"; t="warm"; d="medium"; tags=@("home","meaning","family","comfort","belonging"); people=@(); places=@("home"); diff="easy"; pri="core" },
    @{ q="Describe the home where you raised your children."; p="Paints a picture of the family home"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("home","children","family house","raised","description"); people=@("children"); places=@("family home"); diff="easy"; pri="core" },
    @{ q="What was your favourite room and why?"; p="Identifies most cherished home space"; m="descriptive"; t="warm"; d="medium"; tags=@("favourite room","home","comfort","space","special"); people=@(); places=@("room"); diff="easy"; pri="secondary" },
    @{ q="What did your home smell like?"; p="Captures sensory home memories"; m="sensory"; t="nostalgic"; d="short"; tags=@("smell","home","scent","sensory","cooking"); people=@(); places=@("home"); diff="easy"; pri="secondary" },
    @{ q="What was the view from your window?"; p="Captures the visual world outside the home"; m="descriptive"; t="nostalgic"; d="short"; tags=@("window","view","home","outside","neighbourhood"); people=@(); places=@("home","neighbourhood"); diff="easy"; pri="secondary" },
    @{ q="What family rituals did you have at home?"; p="Documents family rituals and routines"; m="descriptive"; t="warm"; d="medium"; tags=@("rituals","routines","family","home","traditions"); people=@("family"); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="What was dinnertime like in your family?"; p="Explores family mealtime culture"; m="descriptive"; t="warm"; d="medium"; tags=@("dinner","meal","family","mealtime","conversation"); people=@("family"); places=@("dining room","kitchen"); diff="easy"; pri="secondary" },
    @{ q="How did you make your house feel like a home?"; p="Explores ways of creating home comfort"; m="reflective"; t="thoughtful"; d="medium"; tags=@("house","home","comfort","decoration","atmosphere"); people=@(); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="Did you have a garden or outdoor space? What did you do there?"; p="Explores outdoor family life"; m="descriptive"; t="playful"; d="medium"; tags=@("garden","outdoor","space","play","relax"); people=@("family"); places=@("garden"); diff="easy"; pri="secondary" },
    @{ q="What sounds did your home make?"; p="Captures auditory home memories"; m="sensory"; t="nostalgic"; d="medium"; tags=@("sounds","home","noise","music","voices"); people=@("family"); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="How did your children's friends feel about coming to your home?"; p="Explores home as a welcoming space for others"; m="descriptive"; t="proud"; d="medium"; tags=@("children","friends","welcoming","home","comfortable"); people=@("children","friends"); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="What was the most peaceful moment you remember at home?"; p="Captures quiet, treasured home moments"; m="narrative"; t="peaceful"; d="medium"; tags=@("peaceful","moment","quiet","home","calm"); people=@(); places=@("home"); diff="medium"; pri="core" },
    @{ q="Did your home have any quirks or special features?"; p="Captures unique home characteristics"; m="descriptive"; t="amused"; d="medium"; tags=@("quirks","features","unique","special","home"); people=@(); places=@("home"); diff="easy"; pri="secondary" },
    @{ q="How does your home now compare to the home you raised your family in?"; p="Explores change and continuity in home life"; m="reflective"; t="thoughtful"; d="medium"; tags=@("home","now","compare","change","evolution"); people=@(); places=@("current home","past home"); diff="medium"; pri="secondary" },
    @{ q="What do you want your family to remember about the home you built?"; p="Captures legacy of the family home"; m="reflective"; t="purposeful"; d="medium"; tags=@("remember","home","family","legacy","memories"); people=@("family"); places=@("home"); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch12Questions) {
    $id = "ch12_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch12"; chapterNumber = 12; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 13: Festivals, Food and Traditions
$ch13Questions = @(
    @{ q="What festivals or holidays did your family celebrate?"; p="Documents family celebrations and holidays"; m="descriptive"; t="joyful"; d="medium"; tags=@("festivals","holidays","celebrations","family","events"); people=@("family"); places=@(); diff="easy"; pri="core" },
    @{ q="What was your favourite festival as a child?"; p="Captures childhood festival memories"; m="narrative"; t="excited"; d="medium"; tags=@("favourite","festival","childhood","celebration","special"); people=@("family"); places=@(); diff="easy"; pri="core" },
    @{ q="Tell me about the food you ate during festivals."; p="Captures festival food traditions"; m="sensory"; t="warm"; d="medium"; tags=@("food","festival","cooking","recipes","meals"); people=@("mother","grandmother"); places=@("kitchen"); diff="easy"; pri="core" },
    @{ q="Who was the best cook in your family? What did they make?"; p="Identifies family cooks and signature dishes"; m="descriptive"; t="appreciative"; d="medium"; tags=@("cook","cooking","recipes","best","signature dish"); people=@("grandmother","mother","aunt"); places=@("kitchen"); diff="easy"; pri="secondary" },
    @{ q="What is one recipe you want to pass down?"; p="Captures heirloom recipes and food legacy"; m="factual"; t="purposeful"; d="medium"; tags=@("recipe","pass down","family","heirloom","food"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="Were there any special foods you only ate on certain occasions?"; p="Explores occasion-specific food traditions"; m="descriptive"; t="nostalgic"; d="medium"; tags=@("special food","occasion","festival","only","treat"); people=@(); places=@(); diff="easy"; pri="secondary" },
    @{ q="What decorations or preparations did your family make for celebrations?"; p="Captures festive preparations and decorations"; m="descriptive"; t="excited"; d="medium"; tags=@("decorations","preparations","celebration","festival","home"); people=@("family"); places=@("home"); diff="easy"; pri="secondary" },
    @{ q="Did your family have any unique traditions that others didn't?"; p="Captures distinctive family customs"; m="narrative"; t="proud"; d="medium"; tags=@("unique","traditions","customs","family","special"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="How did you celebrate birthdays in your family?"; p="Explores birthday traditions and celebrations"; m="descriptive"; t="happy"; d="medium"; tags=@("birthdays","celebration","cake","traditions","party"); people=@("family","children"); places=@("home"); diff="easy"; pri="secondary" },
    @{ q="What music or songs were part of your celebrations?"; p="Captures musical traditions in celebrations"; m="descriptive"; t="joyful"; d="medium"; tags=@("music","songs","celebration","festival","singing"); people=@("family"); places=@(); diff="easy"; pri="secondary" },
    @{ q="What traditional clothes did you wear for special occasions?"; p="Captures clothing traditions for celebrations"; m="descriptive"; t="proud"; d="medium"; tags=@("clothes","traditional","special","occasion","dressed up"); people=@("family"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Which traditions did you continue with your own children?"; p="Explores tradition continuity across generations"; m="reflective"; t="purposeful"; d="medium"; tags=@("continue","traditions","children","generations","passed on"); people=@("children"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the most beautiful celebration you remember?"; p="Identifies most memorable celebration"; m="narrative"; t="awestruck"; d="medium"; tags=@("beautiful","celebration","memorable","festival","special"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="How did the way you celebrated change over the years?"; p="Explores evolution of traditions over time"; m="reflective"; t="thoughtful"; d="medium"; tags=@("change","celebration","years","evolution","traditions"); people=@("family"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What do you want future generations to know about your family's traditions?"; p="Captures tradition legacy for future generations"; m="reflective"; t="purposeful"; d="medium"; tags=@("future generations","traditions","legacy","know","pass on"); people=@("future generations"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch13Questions) {
    $id = "ch13_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch13"; chapterNumber = 13; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 14: Challenges and Difficult Times
$ch14Questions = @(
    @{ q="What was the most difficult period of your life?"; p="Identifies greatest life challenge"; m="narrative"; t="empathetic"; d="long"; tags=@("difficult","hardest","period","challenge","struggle"); people=@(); places=@(); diff="hard"; pri="core" },
    @{ q="How did you cope when things got really hard?"; p="Explores coping mechanisms and resilience"; m="reflective"; t="empathetic"; d="medium"; tags=@("cope","hard","resilience","mechanism","survive"); people=@(); places=@(); diff="hard"; pri="core" },
    @{ q="Did you ever lose someone you loved? How did you get through it?"; p="Explores grief and loss experiences"; m="emotional"; t="tender"; d="long"; tags=@("loss","grief","death","loved one","mourning"); people=@("loved one","family member"); places=@(); diff="hard"; pri="core" },
    @{ q="Have you ever had a serious illness? What was that like?"; p="Explores health challenges"; m="narrative"; t="empathetic"; d="medium"; tags=@("illness","health","sick","recovery","challenge"); people=@("family"); places=@("hospital"); diff="hard"; pri="secondary" },
    @{ q="Did you ever face a financial crisis? How did you handle it?"; p="Explores financial challenges and resourcefulness"; m="narrative"; t="honest"; d="medium"; tags=@("financial","crisis","money","difficulty","survive"); people=@("spouse"); places=@(); diff="hard"; pri="secondary" },
    @{ q="Who helped you during your hardest times?"; p="Identifies support systems during adversity"; m="emotional"; t="grateful"; d="medium"; tags=@("helped","support","hardest","grateful","people"); people=@("friend","family","helper"); places=@(); diff="medium"; pri="core" },
    @{ q="What did you learn about yourself through hardship?"; p="Explores personal growth through adversity"; m="reflective"; t="wise"; d="medium"; tags=@("learned","myself","hardship","growth","strength"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Was there a time you felt completely alone? What happened?"; p="Explores loneliness and isolation"; m="emotional"; t="empathetic"; d="medium"; tags=@("alone","lonely","isolated","difficulty","struggle"); people=@(); places=@(); diff="hard"; pri="secondary" },
    @{ q="How did you find the courage to keep going?"; p="Explores sources of strength and motivation"; m="reflective"; t="inspiring"; d="medium"; tags=@("courage","keep going","strength","motivation","perseverance"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Did you ever feel like giving up? What stopped you?"; p="Explores moments of despair and resilience"; m="emotional"; t="honest"; d="medium"; tags=@("giving up","despair","stopped","resilience","hope"); people=@(); places=@(); diff="hard"; pri="secondary" },
    @{ q="How did your faith or beliefs help you through hard times?"; p="Explores role of faith in adversity"; m="reflective"; t="reverent"; d="medium"; tags=@("faith","beliefs","hard times","spiritual","strength"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did hardship change the way you see the world?"; p="Explores worldview transformation through adversity"; m="reflective"; t="thoughtful"; d="medium"; tags=@("hardship","world","change","perspective","outlook"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What kept your family together during tough times?"; p="Explores family resilience and bonding"; m="reflective"; t="grateful"; d="medium"; tags=@("family","together","tough","resilience","bond"); people=@("family"); places=@(); diff="medium"; pri="secondary" },
    @{ q="If you could go back and help your younger self, what would you say?"; p="Captures self-compassion and wisdom"; m="reflective"; t="compassionate"; d="medium"; tags=@("younger self","advice","help","compassion","wisdom"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What message of hope would you give to someone going through a hard time right now?"; p="Generates wisdom from experience for others"; m="reflective"; t="hopeful"; d="medium"; tags=@("hope","message","hard time","wisdom","encouragement"); people=@(); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch14Questions) {
    $id = "ch14_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch14"; chapterNumber = 14; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 15: Successes and Turning Points
$ch15Questions = @(
    @{ q="What is the achievement you are most proud of?"; p="Identifies proudest accomplishment"; m="reflective"; t="proud"; d="medium"; tags=@("achievement","proud","success","accomplishment","pride"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What was the biggest turning point in your life?"; p="Identifies transformative life moment"; m="narrative"; t="reflective"; d="long"; tags=@("turning point","change","life","transformative","moment"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Tell me about a time you succeeded against the odds."; p="Captures triumph over adversity"; m="narrative"; t="inspiring"; d="long"; tags=@("succeeded","odds","triumph","overcame","success"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What was the best decision you ever made?"; p="Identifies most impactful positive decision"; m="reflective"; t="satisfied"; d="medium"; tags=@("best decision","choice","right","impactful","life"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What was a risk that paid off?"; p="Explores successful risk-taking"; m="narrative"; t="excited"; d="medium"; tags=@("risk","paid off","gamble","bold","reward"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did you ever have a moment where everything changed?"; p="Captures life-altering moments"; m="narrative"; t="reflective"; d="medium"; tags=@("moment","changed","everything","transformed","new"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is something you achieved that no one thought you could?"; p="Captures underdog success stories"; m="narrative"; t="proud"; d="medium"; tags=@("achieved","thought","impossible","underdog","success"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How did you celebrate your successes?"; p="Explores celebration habits and joy"; m="descriptive"; t="happy"; d="medium"; tags=@("celebrate","success","joy","happy","achievement"); people=@("family","friends"); places=@(); diff="easy"; pri="secondary" },
    @{ q="Who shared in your proudest moment?"; p="Identifies people present at peak moments"; m="descriptive"; t="warm"; d="medium"; tags=@("shared","proudest","moment","family","friends"); people=@("family","friends"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What opportunity changed the course of your life?"; p="Explores pivotal opportunities"; m="narrative"; t="reflective"; d="medium"; tags=@("opportunity","changed","course","life","lucky"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="How did success change you?"; p="Explores impact of success on character"; m="reflective"; t="thoughtful"; d="medium"; tags=@("success","changed","impact","person","growth"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What does success mean to you now compared to when you were young?"; p="Explores evolving definition of success"; m="reflective"; t="wise"; d="medium"; tags=@("success","meaning","now","young","definition"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What moment in your life would you relive if you could?"; p="Identifies most cherished life moment"; m="reflective"; t="nostalgic"; d="medium"; tags=@("relive","moment","cherished","favourite","life"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the most important lesson success taught you?"; p="Extracts wisdom from achievement"; m="reflective"; t="wise"; d="medium"; tags=@("lesson","success","taught","wisdom","important"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What advice would you give someone who wants to succeed?"; p="Shares success wisdom with others"; m="reflective"; t="wise"; d="medium"; tags=@("advice","succeed","success","wisdom","share"); people=@(); places=@(); diff="medium"; pri="secondary" }
)

$qNum = 1
foreach ($q in $ch15Questions) {
    $id = "ch15_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch15"; chapterNumber = 15; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 16: Faith, Values and Beliefs
$ch16Questions = @(
    @{ q="What faith or spiritual practice has guided your life?"; p="Explores core spiritual identity"; m="reflective"; t="reverent"; d="medium"; tags=@("faith","spiritual","practice","guided","religion"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How did your faith develop over your lifetime?"; p="Explores spiritual journey and evolution"; m="narrative"; t="reflective"; d="long"; tags=@("faith","develop","journey","evolution","spiritual"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What values do you hold most important?"; p="Identifies core personal values"; m="reflective"; t="serious"; d="medium"; tags=@("values","important","beliefs","principles","morals"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Who taught you these values?"; p="Identifies values mentors and teachers"; m="reflective"; t="grateful"; d="medium"; tags=@("taught","values","learned","mentor","parents"); people=@("parents","grandparents","teacher"); places=@(); diff="medium"; pri="secondary" },
    @{ q="Do you believe in something greater than yourself?"; p="Explores spiritual or philosophical worldview"; m="reflective"; t="thoughtful"; d="medium"; tags=@("believe","greater","spiritual","philosophical","meaning"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="How do you find peace in difficult times?"; p="Explores spiritual coping and inner resources"; m="reflective"; t="peaceful"; d="medium"; tags=@("peace","difficult","spiritual","coping","calm"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What role has prayer or meditation played in your life?"; p="Explores spiritual practices and their impact"; m="reflective"; t="reverent"; d="medium"; tags=@("prayer","meditation","spiritual","practice","peace"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Have your beliefs ever been challenged? How did you respond?"; p="Explores faith testing and resilience"; m="narrative"; t="honest"; d="medium"; tags=@("beliefs","challenged","tested","response","doubt"); people=@(); places=@(); diff="hard"; pri="secondary" },
    @{ q="What moral lesson do you want to pass on?"; p="Identifies core moral teachings for legacy"; m="reflective"; t="purposeful"; d="medium"; tags=@("moral","lesson","pass on","values","teaching"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How do you define a good life?"; p="Explores personal philosophy of life"; m="reflective"; t="wise"; d="medium"; tags=@("good life","define","philosophy","meaning","purpose"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What gives your life meaning?"; p="Explores sources of purpose and fulfilment"; m="reflective"; t="purposeful"; d="medium"; tags=@("meaning","purpose","fulfilment","reason","life"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How has your relationship with faith changed over the years?"; p="Explores spiritual evolution"; m="reflective"; t="thoughtful"; d="medium"; tags=@("faith","changed","years","evolution","relationship"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What role has community played in your spiritual life?"; p="Explores communal spiritual experiences"; m="reflective"; t="warm"; d="medium"; tags=@("community","spiritual","church","temple","group"); people=@(); places=@("place of worship"); diff="medium"; pri="secondary" },
    @{ q="What do you hope for the world?"; p="Explores hopes and visions for humanity"; m="reflective"; t="hopeful"; d="medium"; tags=@("hope","world","future","humanity","vision"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What would you want your grandchildren to believe about the world?"; p="Captures core beliefs for future legacy"; m="reflective"; t="purposeful"; d="medium"; tags=@("grandchildren","believe","world","values","legacy"); people=@("grandchildren"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch16Questions) {
    $id = "ch16_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch16"; chapterNumber = 16; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 17: Travel and Adventures
$ch17Questions = @(
    @{ q="What was the first place you ever travelled to?"; p="Captures earliest travel experience"; m="narrative"; t="excited"; d="medium"; tags=@("travel","first","place","journey","trip"); people=@(); places=@("destination"); diff="easy"; pri="core" },
    @{ q="What is the most beautiful place you have ever seen?"; p="Identifies most visually stunning experience"; m="descriptive"; t="awestruck"; d="medium"; tags=@("beautiful","place","seen","stunning","amazing"); people=@(); places=@("beautiful place"); diff="easy"; pri="core" },
    @{ q="Tell me about a trip that changed your perspective."; p="Explores transformative travel experiences"; m="narrative"; t="reflective"; d="long"; tags=@("trip","changed","perspective","transformative","travel"); people=@(); places=@("destination"); diff="medium"; pri="core" },
    @{ q="What country or culture fascinated you most?"; p="Explores cultural curiosity and appreciation"; m="descriptive"; t="curious"; d="medium"; tags=@("country","culture","fascinated","interested","different"); people=@(); places=@("country","culture"); diff="easy"; pri="secondary" },
    @{ q="Did you ever have a travel adventure or mishap?"; p="Captures funny or challenging travel stories"; m="narrative"; t="humorous"; d="medium"; tags=@("adventure","mishap","funny","travel","story"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was your favourite family holiday?"; p="Identifies most cherished family travel"; m="narrative"; t="happy"; d="medium"; tags=@("favourite","family","holiday","vacation","best"); people=@("family"); places=@("holiday destination"); diff="easy"; pri="core" },
    @{ q="Did travel teach you anything about yourself?"; p="Explores self-discovery through travel"; m="reflective"; t="thoughtful"; d="medium"; tags=@("travel","learned","myself","discovery","growth"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What was the most memorable meal you had while travelling?"; p="Captures culinary travel memories"; m="sensory"; t="delighted"; d="medium"; tags=@("meal","memorable","food","travel","delicious"); people=@(); places=@("restaurant","country"); diff="easy"; pri="secondary" },
    @{ q="Did you travel alone or with others? What was that like?"; p="Explores solo vs group travel experiences"; m="reflective"; t="thoughtful"; d="medium"; tags=@("alone","with others","solo","group","travel"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What place did you always want to visit but never did?"; p="Explores unfulfilled travel dreams"; m="reflective"; t="wistful"; d="medium"; tags=@("wanted","visit","never","dream","place"); people=@(); places=@("dream destination"); diff="medium"; pri="secondary" },
    @{ q="How did you feel when you returned home from a long trip?"; p="Explores the feeling of coming home"; m="emotional"; t="nostalgic"; d="medium"; tags=@("returned","home","long trip","feeling","missing"); people=@(); places=@("home"); diff="medium"; pri="secondary" },
    @{ q="What did you learn from people in other countries?"; p="Explores cross-cultural learning"; m="reflective"; t="appreciative"; d="medium"; tags=@("learned","people","countries","culture","different"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="Did your children enjoy travelling? What trips do they remember?"; p="Explores family travel through children's eyes"; m="descriptive"; t="warm"; d="medium"; tags=@("children","enjoy","travelling","remember","family"); people=@("children"); places=@(); diff="easy"; pri="secondary" },
    @{ q="What would be your dream trip if you could go anywhere?"; p="Explores unfulfilled travel aspirations"; m="reflective"; t="hopeful"; d="medium"; tags=@("dream","trip","anywhere","wish","travel"); people=@(); places=@("dream destination"); diff="easy"; pri="secondary" },
    @{ q="What place will you never forget? Why?"; p="Identifies most impactful travel destination"; m="reflective"; t="meaningful"; d="medium"; tags=@("never forget","place","impactful","memory","special"); people=@(); places=@("special place"); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch17Questions) {
    $id = "ch17_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch17"; chapterNumber = 17; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 18: Wisdom and Life Lessons
$ch18Questions = @(
    @{ q="What is the most important lesson life has taught you?"; p="Captures core life wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("important","lesson","life","taught","wisdom"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What advice would you give to your younger self?"; p="Extracts self-compassion and wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("advice","younger self","wisdom","regret","learning"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What do you know now that you wish you knew earlier?"; p="Identifies hard-won knowledge"; m="reflective"; t="thoughtful"; d="medium"; tags=@("know","wish","earlier","learning","wisdom"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What does it mean to live well?"; p="Explores personal philosophy of good living"; m="reflective"; t="wise"; d="medium"; tags=@("live well","meaning","philosophy","good life","purpose"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How do you define happiness?"; p="Explores personal definition of happiness"; m="reflective"; t="thoughtful"; d="medium"; tags=@("happiness","define","meaning","joy","contentment"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the secret to a long life?"; p="Extracts longevity wisdom"; m="reflective"; t="wise"; d="medium"; tags=@("secret","long life","longevity","health","living"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What should young people know about growing old?"; p="Shares wisdom about aging"; m="reflective"; t="honest"; d="medium"; tags=@("young","growing old","aging","wisdom","truth"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What do you value most in life?"; p="Identifies core life values"; m="reflective"; t="serious"; d="medium"; tags=@("value","most","life","important","priorities"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How has your understanding of wisdom changed?"; p="Explores evolving understanding of wisdom"; m="reflective"; t="thoughtful"; d="medium"; tags=@("wisdom","understanding","changed","evolved","growth"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the hardest truth you've learned?"; p="Captures difficult life lessons"; m="reflective"; t="honest"; d="medium"; tags=@("hardest","truth","learned","lesson","reality"); people=@(); places=@(); diff="hard"; pri="core" },
    @{ q="How do you handle regret?"; p="Explores approach to regret and acceptance"; m="reflective"; t="thoughtful"; d="medium"; tags=@("regret","handle","acceptance","peace","letting go"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What does courage mean to you?"; p="Explores personal understanding of courage"; m="reflective"; t="thoughtful"; d="medium"; tags=@("courage","brave","fear","meaning","strength"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What role has patience played in your life?"; p="Explores the value of patience"; m="reflective"; t="wise"; d="medium"; tags=@("patience","life","role","waiting","perseverance"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What is the best piece of advice you ever received?"; p="Captures most impactful advice"; m="reflective"; t="grateful"; d="medium"; tags=@("best","advice","received","wisdom","impact"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="If you had to summarise your life in three sentences, what would they be?"; p="Captures self-summary and life essence"; m="reflective"; t="purposeful"; d="medium"; tags=@("summarise","life","three sentences","essence","summary"); people=@(); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch18Questions) {
    $id = "ch18_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch18"; chapterNumber = 18; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 19: Legacy for Future Generations
$ch19Questions = @(
    @{ q="What do you want your grandchildren to know about you?"; p="Captures core legacy message"; m="reflective"; t="purposeful"; d="medium"; tags=@("grandchildren","know","you","legacy","message"); people=@("grandchildren"); places=@(); diff="medium"; pri="core" },
    @{ q="What family stories do you want to make sure are never forgotten?"; p="Identifies stories for preservation"; m="reflective"; t="purposeful"; d="medium"; tags=@("stories","never forgotten","family","preserve","legacy"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="What values do you hope you passed on to your children?"; p="Explores values transmission across generations"; m="reflective"; t="hopeful"; d="medium"; tags=@("values","passed on","children","hope","legacy"); people=@("children"); places=@(); diff="medium"; pri="core" },
    @{ q="What would you want your family to remember about the times you lived through?"; p="Captures historical context for legacy"; m="reflective"; t="purposeful"; d="medium"; tags=@("remember","times","lived","historical","legacy"); people=@("family"); places=@(); diff="medium"; pri="secondary" },
    @{ q="What tradition would you most like to see continue?"; p="Identifies most important tradition for continuity"; m="reflective"; t="purposeful"; d="medium"; tags=@("tradition","continue","important","preserve","pass on"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What do you want people to say about you at your funeral?"; p="Explores desired legacy and remembrance"; m="reflective"; t="purposeful"; d="medium"; tags=@("say","funeral","remember","legacy","wish"); people=@(); places=@(); diff="hard"; pri="core" },
    @{ q="What would you like to be remembered for?"; p="Identifies desired legacy and impact"; m="reflective"; t="purposeful"; d="medium"; tags=@("remembered","legacy","impact","meaning","life"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the one thing you would want to tell every person in the world?"; p="Captures universal message from life experience"; m="reflective"; t="purposeful"; d="medium"; tags=@("tell","world","everyone","message","important"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How do you want your family to feel when they read your story?"; p="Explores desired emotional impact of autobiography"; m="reflective"; t="tender"; d="medium"; tags=@("feel","family","read","story","emotion"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="What has your life taught you about what really matters?"; p="Captures ultimate life lesson"; m="reflective"; t="wise"; d="medium"; tags=@("life","taught","matters","important","lesson"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What are you most grateful for?"; p="Identifies deepest gratitude"; m="reflective"; t="grateful"; d="medium"; tags=@("grateful","thankful","appreciate","gratitude","life"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What message of love would you leave for your family?"; p="Captures final love message"; m="reflective"; t="loving"; d="medium"; tags=@("love","message","family","leave","heart"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="How do you hope the world will be different because you were here?"; p="Explores impact and legacy on the world"; m="reflective"; t="hopeful"; d="medium"; tags=@("hope","world","different","impact","legacy"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the most important thing you want your family to know about love?"; p="Captures love wisdom for family"; m="reflective"; t="loving"; d="medium"; tags=@("love","family","know","important","wisdom"); people=@("family"); places=@(); diff="medium"; pri="core" },
    @{ q="If you could write a letter to the future, what would it say?"; p="Captures message to future generations"; m="reflective"; t="purposeful"; d="medium"; tags=@("letter","future","generations","message","time capsule"); people=@("future generations"); places=@(); diff="medium"; pri="core" }
)

$qNum = 1
foreach ($q in $ch19Questions) {
    $id = "ch19_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch19"; chapterNumber = 19; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Chapter 20: Final Reflections
$ch20Questions = @(
    @{ q="Looking back on your whole life, what are you most grateful for?"; p="Captures ultimate gratitude"; m="reflective"; t="grateful"; d="medium"; tags=@("grateful","whole life","thankful","gratitude","appreciate"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What was the happiest time of your life?"; p="Identifies peak happiness period"; m="reflective"; t="joyful"; d="medium"; tags=@("happiest","time","life","joy","best"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="If you could live your life over, what would you do differently?"; p="Explores life reflection and acceptance"; m="reflective"; t="thoughtful"; d="medium"; tags=@("live over","differently","regret","reflection","acceptance"); people=@(); places=@(); diff="hard"; pri="core" },
    @{ q="What makes you smile when you think about your life?"; p="Identifies joyful life memories"; m="reflective"; t="smiling"; d="medium"; tags=@("smile","think","life","happy","joy"); people=@(); places=@(); diff="easy"; pri="core" },
    @{ q="What was the most meaningful relationship of your life?"; p="Identifies most important relationship"; m="reflective"; t="loving"; d="medium"; tags=@("meaningful","relationship","love","important","bond"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How do you want to be remembered?"; p="Explores desired remembrance and legacy"; m="reflective"; t="purposeful"; d="medium"; tags=@("remembered","legacy","wish","memory","impact"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the meaning of life, according to you?"; p="Explores personal philosophy of meaning"; m="reflective"; t="wise"; d="medium"; tags=@("meaning","life","philosophy","purpose","wisdom"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What are you at peace with now?"; p="Explores acceptance and inner peace"; m="reflective"; t="peaceful"; d="medium"; tags=@("peace","at peace","acceptance","contentment","calm"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What would you like to say to your children and grandchildren right now?"; p="Captures direct message to family"; m="reflective"; t="loving"; d="medium"; tags=@("say","children","grandchildren","message","love"); people=@("children","grandchildren"); places=@(); diff="medium"; pri="core" },
    @{ q="What legacy do you hope to leave behind?"; p="Captures desired legacy impact"; m="reflective"; t="purposeful"; d="medium"; tags=@("legacy","hope","leave","impact","meaning"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What is the most beautiful thing about life?"; p="Explores appreciation for life's beauty"; m="reflective"; t="appreciative"; d="medium"; tags=@("beautiful","life","appreciate","wonder","gift"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="How has life surprised you?"; p="Explores unexpected life turns and gifts"; m="reflective"; t="amazed"; d="medium"; tags=@("surprised","life","unexpected","gift","wonder"); people=@(); places=@(); diff="medium"; pri="secondary" },
    @{ q="What do you know for certain about life?"; p="Captures absolute life truths"; m="reflective"; t="wise"; d="medium"; tags=@("certain","life","truth","know","certainty"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="What has been the greatest gift of your life?"; p="Identifies greatest life gift"; m="reflective"; t="grateful"; d="medium"; tags=@("greatest","gift","life","blessing","treasure"); people=@(); places=@(); diff="medium"; pri="core" },
    @{ q="Is there anything we haven't talked about that you'd like to share?"; p="Captures any remaining important stories"; m="reflective"; t="open"; d="long"; tags=@("share","talked about","important","remaining","final"); people=@(); places=@(); diff="easy"; pri="core" }
)

$qNum = 1
foreach ($q in $ch20Questions) {
    $id = "ch20_q{0:D2}" -f $qNum
    $questions += @{
        id = $id; chapterId = "ch20"; chapterNumber = 20; questionNumber = $qNum
        question = $q.q; purpose = $q.p; expectedMemoryType = $q.m; emotionalTone = $q.t
        estimatedDuration = $q.d; searchTags = $q.tags; people = $q.people; places = $q.places
        difficulty = $q.diff; priority = $q.pri
    }
    $qNum++
}

# Build the final output
$output = @{
    version = "1.0"
    totalQuestions = $questions.Count
    questions = $questions
} | ConvertTo-Json -Depth 5

$output | Out-File -FilePath "C:\Users\kush_\my_parents_story\question_metadata.json" -Encoding utf8
Write-Host "Created question_metadata.json with $($questions.Count) questions"
