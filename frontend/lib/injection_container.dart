import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/authentication/data/data_sources/remote/firebase_auth_service.dart';
import 'features/authentication/data/repository/auth_repository_impl.dart';
import 'features/authentication/domain/repository/auth_repository.dart';
import 'features/authentication/domain/use_cases/get_current_user.dart';
import 'features/authentication/domain/use_cases/request_password_reset.dart';
import 'features/authentication/domain/use_cases/sign_in.dart';
import 'features/authentication/domain/use_cases/sign_out.dart';
import 'features/authentication/domain/use_cases/sign_up.dart';
import 'features/authentication/presentation/bloc/password_reset/password_reset_cubit.dart';
import 'features/authentication/presentation/bloc/session/session_cubit.dart';
import 'features/journalist_articles/data/data_sources/remote/article_storage_service.dart';
import 'features/journalist_articles/data/data_sources/remote/firestore_article_service.dart';
import 'features/journalist_articles/data/repository/article_thumbnail_repository_impl.dart';
import 'features/journalist_articles/data/repository/journalist_article_repository_impl.dart';
import 'features/journalist_articles/domain/repository/article_thumbnail_repository.dart';
import 'features/journalist_articles/domain/repository/journalist_article_repository.dart';
import 'features/journalist_articles/domain/use_cases/create_article.dart';
import 'features/journalist_articles/domain/use_cases/delete_article.dart';
import 'features/journalist_articles/domain/use_cases/get_article_by_id.dart';
import 'features/journalist_articles/domain/use_cases/get_my_articles.dart';
import 'features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'features/journalist_articles/domain/use_cases/increment_article_view_count.dart';
import 'features/journalist_articles/domain/use_cases/publish_article.dart';
import 'features/journalist_articles/domain/use_cases/update_article.dart';
import 'features/journalist_articles/domain/use_cases/upload_article_thumbnail.dart';
import 'features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl())
  );
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );


  // Firebase services
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Authentication feature
  sl.registerSingleton<FirebaseAuthService>(FirebaseAuthService(sl()));

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl())
  );

  sl.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(sl())
  );

  sl.registerSingleton<SignUpUseCase>(
    SignUpUseCase(sl())
  );

  sl.registerSingleton<SignInUseCase>(
    SignInUseCase(sl())
  );

  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl())
  );

  sl.registerSingleton<RequestPasswordResetUseCase>(
    RequestPasswordResetUseCase(sl())
  );

  // Journalist articles feature
  // This is the swap decision #6 was written for: the in memory
  // implementations are still in the repository as a fixture that runs with no
  // network, and plugging Firestore in was a change in these two lines.
  sl.registerSingleton<FirestoreArticleService>(FirestoreArticleService(sl()));
  sl.registerSingleton<ArticleStorageService>(ArticleStorageService(sl()));

  sl.registerSingleton<JournalistArticleRepository>(
    JournalistArticleRepositoryImpl(sl())
  );

  sl.registerSingleton<ArticleThumbnailRepository>(
    ArticleThumbnailRepositoryImpl(sl())
  );

  sl.registerSingleton<GetMyArticlesUseCase>(
    GetMyArticlesUseCase(sl())
  );

  sl.registerSingleton<GetArticleByIdUseCase>(
    GetArticleByIdUseCase(sl())
  );

  sl.registerSingleton<CreateArticleUseCase>(
    CreateArticleUseCase(sl())
  );

  sl.registerSingleton<UpdateArticleUseCase>(
    UpdateArticleUseCase(sl())
  );

  sl.registerSingleton<PublishArticleUseCase>(
    PublishArticleUseCase(sl())
  );

  sl.registerSingleton<DeleteArticleUseCase>(
    DeleteArticleUseCase(sl())
  );

  sl.registerSingleton<UploadArticleThumbnailUseCase>(
    UploadArticleThumbnailUseCase(sl())
  );

  sl.registerSingleton<GetPublishedArticlesUseCase>(
    GetPublishedArticlesUseCase(sl())
  );

  sl.registerSingleton<IncrementArticleViewCountUseCase>(
    IncrementArticleViewCountUseCase(sl())
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  // One session for the whole app: the account button, the route guards and
  // the article cubits all read this same instance.
  sl.registerSingleton<SessionCubit>(
    SessionCubit(sl(), sl(), sl(), sl())
  );

  sl.registerFactory<PasswordResetCubit>(
    ()=> PasswordResetCubit(sl())
  );

  // MyArticlesCubit and ArticleEditorCubit are not registered here: they need
  // the signed in journalist's id, which is only known at navigation time.
  // AppRoutes composes them with sl<...UseCase>() and the session user, the
  // same way it does for ArticleFeedCubit.

  // General "community articles" feed. The "more from this author" variant
  // needs an authorId only known at navigation time, so AppRoutes constructs
  // it directly with sl<GetPublishedArticlesUseCase>() instead of through
  // this factory (see AppRoutes._articleFeedScreen).
  sl.registerFactory<ArticleFeedCubit>(
    ()=> ArticleFeedCubit(sl())
  );

}