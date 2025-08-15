package dev.aayu

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import dev.aayu.nav.AayuNavigation
import dev.aayu.ui.theme.AayuTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AayuTheme {
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    AayuNavigation()
                }
            }
        }
    }
}