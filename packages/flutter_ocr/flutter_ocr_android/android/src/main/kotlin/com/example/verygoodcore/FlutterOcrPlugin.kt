package com.example.verygoodcore

import android.net.Uri
import androidx.core.net.toUri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterOcrPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.pluginBinding = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_ocr_android")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "getPlatformName" -> {
                result.success("Android ML Kit")
            }

            "recognizeTextFromImage" -> {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath == null || imagePath.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "imagePath is null or empty", null)
                    return
                }

                recognizeText(imagePath, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun recognizeText(imagePath: String, result: Result) {
        try {
            // Convert to valid file:// URI if direct file path is passed
            val uri = if (imagePath.startsWith("file://")) {
                imagePath.toUri()
            } else {
                Uri.fromFile(java.io.File(imagePath))
            }

            val image = InputImage.fromFilePath(pluginBinding.applicationContext, uri)
            val recognizer = TextRecognition.getClient(
                TextRecognizerOptions
                    .DEFAULT_OPTIONS
            )

            recognizer.process(image)
                .addOnSuccessListener { recognizedText ->
                    result.success(recognizedText.text)
                    recognizer.close()
                }
                .addOnFailureListener { e ->
                    result.error("OCR_FAILED", e.localizedMessage ?: "Unknown error", null)
                    recognizer.close()
                }

        } catch (e: Exception) {
            result.error("OCR_EXCEPTION", e.localizedMessage ?: "Exception occurred", null)
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}