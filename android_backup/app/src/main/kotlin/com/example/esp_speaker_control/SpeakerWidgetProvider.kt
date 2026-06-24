package com.example.esp_speaker_control

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SpeakerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val powerPendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("speakerWidget://power")
                )
                setOnClickPendingIntent(R.id.btn_power, powerPendingIntent)

                val volDownPendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("speakerWidget://vol_down")
                )
                setOnClickPendingIntent(R.id.btn_vol_down, volDownPendingIntent)

                val mutePendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("speakerWidget://mute")
                )
                setOnClickPendingIntent(R.id.btn_mute, mutePendingIntent)

                val volUpPendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("speakerWidget://vol_up")
                )
                setOnClickPendingIntent(R.id.btn_vol_up, volUpPendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}