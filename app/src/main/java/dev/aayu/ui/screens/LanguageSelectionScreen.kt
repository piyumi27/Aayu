package dev.aayu.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.aayu.R
import dev.aayu.ui.theme.AayuTheme

enum class Language(val displayName: String, val localName: String, val flagIcon: Int) {
    SINHALA("Sinhala", "සිංහල", R.drawable.ic_flag_sri_lanka),
    TAMIL("Tamil", "தமிழ்", R.drawable.ic_flag_india),
    ENGLISH("English", "English", R.drawable.ic_flag_uk)
}

@Composable
fun LanguageSelectionScreen(
    onLanguageSelected: (Language) -> Unit
) {
    var selectedLanguage by remember { mutableStateOf<Language?>(null) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        // Watermark background
        Box(
            modifier = Modifier
                .fillMaxSize()
                .alpha(0.1f)
                .background(Color(0xFF0086FF))
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header
            Text(
                text = "Choose Your Language\nඔබේ භාෂාව තෝරන්න",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 48.dp, bottom = 32.dp)
            )

            // Language Cards
            Column(
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.weight(1f),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(modifier = Modifier.height(32.dp))
                
                Language.values().forEach { language ->
                    LanguageCard(
                        language = language,
                        isSelected = selectedLanguage == language,
                        onClick = { selectedLanguage = language }
                    )
                }
            }

            // Continue Button
            Button(
                onClick = { 
                    selectedLanguage?.let { onLanguageSelected(it) }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .padding(bottom = 32.dp),
                enabled = selectedLanguage != null,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF0086FF),
                    contentColor = Color.White
                ),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text(
                    text = "Continue",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
fun LanguageCard(
    language: Language,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .size(120.dp)
            .clickable { onClick() }
            .then(
                if (isSelected) {
                    Modifier.border(
                        BorderStroke(2.dp, Color(0xFF0086FF)),
                        RoundedCornerShape(12.dp)
                    )
                } else Modifier
            ),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = 4.dp
        )
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Image(
                    painter = painterResource(id = language.flagIcon),
                    contentDescription = "${language.displayName} flag",
                    modifier = Modifier.size(48.dp)
                )
                Text(
                    text = language.localName,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
            
            // Checkmark overlay for selected state
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Color(0xFF0086FF).copy(alpha = 0.1f),
                            RoundedCornerShape(12.dp)
                        )
                )
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = "Selected",
                    tint = Color(0xFF0086FF),
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .size(24.dp)
                )
            }
        }
    }
}

@Preview
@Composable
fun LanguageSelectionScreenPreview() {
    AayuTheme {
        LanguageSelectionScreen(onLanguageSelected = {})
    }
}