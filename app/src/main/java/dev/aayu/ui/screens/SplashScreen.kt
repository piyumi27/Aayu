package dev.aayu.ui.screens

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.aayu.R
import dev.aayu.ui.theme.AayuTheme
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onNavigateToLanguageSelection: () -> Unit
) {
    LaunchedEffect(Unit) {
        delay(2000)
        onNavigateToLanguageSelection()
    }

    val infiniteTransition = rememberInfiniteTransition(label = "splash_animation")
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(
                        Color(0xFFE0F4FF),
                        Color(0xFFB1D9FF)
                    ),
                    start = Offset(0f, 0f),
                    end = Offset(0f, Float.POSITIVE_INFINITY)
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(
                painter = painterResource(id = R.drawable.ic_logo_placeholder),
                contentDescription = "ආයු Logo",
                modifier = Modifier.size(72.dp)
            )
            
            Text(
                text = "ආයු",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF0086FF),
                modifier = Modifier.padding(top = 16.dp)
            )
            
            CircularProgressIndicator(
                modifier = Modifier
                    .padding(top = 24.dp)
                    .size(24.dp)
                    .rotate(rotation),
                color = Color(0xFF0086FF),
                strokeWidth = 2.dp
            )
        }
    }
}

@Preview
@Composable
fun SplashScreenPreview() {
    AayuTheme {
        SplashScreen(onNavigateToLanguageSelection = {})
    }
}