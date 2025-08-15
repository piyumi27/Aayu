package dev.aayu.nav

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import dev.aayu.ui.screens.Language
import dev.aayu.ui.screens.LanguageSelectionScreen
import dev.aayu.ui.screens.SplashScreen

object Routes {
    const val SPLASH = "splash"
    const val LANGUAGE_SELECTION = "language_selection"
    const val HOME = "home"
}

@Composable
fun AayuNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Routes.SPLASH
    ) {
        composable(Routes.SPLASH) {
            SplashScreen(
                onNavigateToLanguageSelection = {
                    navController.navigate(Routes.LANGUAGE_SELECTION) {
                        popUpTo(Routes.SPLASH) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Routes.LANGUAGE_SELECTION) {
            LanguageSelectionScreen(
                onLanguageSelected = { language ->
                    // TODO: Save selected language to preferences
                    navController.navigate(Routes.HOME) {
                        popUpTo(Routes.LANGUAGE_SELECTION) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Routes.HOME) {
            // TODO: Implement Home Screen
            // For now, just show a placeholder
            androidx.compose.material3.Text("Home Screen - Coming Soon")
        }
    }
}