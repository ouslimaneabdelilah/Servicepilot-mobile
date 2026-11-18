import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
class ServicePilotApp extends ConsumerWidget {const ServicePilotApp({super.key}); @override Widget build(BuildContext context,WidgetRef ref){final router=ref.watch(routerProvider);return MaterialApp.router(title:'ServicePilot',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF2457D6)),scaffoldBackgroundColor:const Color(0xFFF6F8FC),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none))),routerConfig:router);}}
