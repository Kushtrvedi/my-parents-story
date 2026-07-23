class HeritageLinenTheme {
  static const String css = '''
    @import url('https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&family=Inter:wght@300;400;600&display=swap');

    :root {
      --paper: #FDFBF7;
      --charcoal: #2C2C2C;
      --gold: #C9A96E;
      --serif: 'Libre Baskerville', serif;
      --sans: 'Inter', sans-serif;
    }

    body {
      background-color: var(--paper);
      color: var(--charcoal);
      font-family: var(--serif);
      line-height: 1.8;
      margin: 0;
      padding: 0;
    }

    h1, h2, h3, h4, h5, h6 {
      font-weight: 400;
      margin: 0;
    }

    /* Paged.js Print Rules */
    @page {
      size: 6in 9in;
      margin: 20mm;
      
      @bottom-center {
        content: counter(page);
        font-family: var(--sans);
        font-size: 10pt;
        color: var(--charcoal);
      }
    }

    @page :left {
      @top-center {
        content: "My Parents' Story";
        font-family: var(--sans);
        font-size: 9pt;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #888;
      }
    }

    @page :right {
      @top-center {
        content: string(chapterTitle);
        font-family: var(--sans);
        font-size: 9pt;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #888;
      }
    }

    /* Cover Page */
    .cover-page {
      break-after: page;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      text-align: center;
    }

    .cover-title {
      font-size: 24pt;
      margin-bottom: 2rem;
      letter-spacing: 2px;
    }

    .cover-subtitle {
      font-family: var(--sans);
      font-size: 10pt;
      letter-spacing: 1px;
      text-transform: uppercase;
      color: var(--gold);
      margin-bottom: 4rem;
    }

    .cover-author {
      font-family: var(--sans);
      font-size: 10pt;
      color: #666;
    }

    /* Chapter Opening */
    .chapter {
      break-before: page;
    }

    .chapter-header {
      text-align: center;
      margin-top: 4rem;
      margin-bottom: 3rem;
    }
    
    .chapter h2 {
      string-set: chapterTitle content();
    }

    .chapter-number {
      font-family: var(--sans);
      font-size: 10pt;
      color: var(--gold);
      letter-spacing: 2px;
      text-transform: uppercase;
      margin-bottom: 1rem;
    }

    .chapter-title {
      font-size: 22pt;
      margin-bottom: 1rem;
    }

    .chapter-dates {
      font-family: var(--sans);
      font-size: 10pt;
      color: #888;
      letter-spacing: 1px;
    }

    .chapter-quote {
      font-style: italic;
      text-align: center;
      font-size: 14pt;
      margin: 3rem auto;
      max-width: 80%;
      color: #555;
    }

    /* Content */
    .content-body {
      text-align: justify;
      font-size: 11pt;
    }

    .content-body p {
      margin-bottom: 1.5rem;
    }

    /* Voice Memories */
    .voice-memory {
      margin-top: 3rem;
      text-align: center;
      border-top: 1px solid var(--gold);
      padding-top: 2rem;
    }
    
    .voice-memory img {
      width: 100px;
      height: 100px;
      margin-top: 1rem;
    }

    .voice-memory p {
      font-family: var(--sans);
      font-size: 9pt;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--gold);
    }
    
    /* Final Page */
    .final-page {
      break-before: page;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      text-align: center;
    }
    
    .final-page p {
      font-size: 12pt;
      margin-bottom: 1rem;
    }
    
    .final-page .platform-credit {
      font-family: var(--sans);
      font-size: 9pt;
      color: #888;
      margin-top: 3rem;
    }
  ''';
}
