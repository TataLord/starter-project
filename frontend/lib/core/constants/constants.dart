const String newsAPIBaseURL = 'https://newsapi.org/v2';
const String newsAPIKey = 'ff957763c54c44d8b00e5e082bc76cb0';
const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage = "https://www.google.com/search?q=default+image&client=firefox-b-d&sxsrf=APq-WBskmtr-ix6NUAqqiHFNpsJX6JSOTg:1650026644151&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjEi_qfjJb3AhXvQd8KHd02BKUQ_AUoAXoECAEQAw#imgrc=A0pMe2lq2NT_jM";

/// Firestore collection holding the articles journalists write.
const String kArticlesCollection = 'articles';

/// Cloud Storage folder holding article cover images, as documented in
/// `backend/docs/DB_SCHEMA.md`.
const String kArticleMediaFolder = 'media/articles';
