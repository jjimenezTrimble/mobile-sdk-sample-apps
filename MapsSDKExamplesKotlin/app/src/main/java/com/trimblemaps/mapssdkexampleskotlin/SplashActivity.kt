package com.trimblemaps.mapssdkexampleskotlin

import android.Manifest
import android.app.Activity
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import com.trimblemaps.android.core.permissions.PermissionsListener
import com.trimblemaps.android.core.permissions.PermissionsManager
import kotlinx.coroutines.*
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors

class SplashActivity : Activity() {


    private val dispatcher: CoroutineDispatcher =
        Executors.newFixedThreadPool(1).asCoroutineDispatcher()
    private val countDownLatch = CountDownLatch(2)

    private val permissionsManager = PermissionsManager(null)
    private val permissionsListener = object: PermissionsListener {
        override fun onExplanationNeeded(permissionsToExplain: MutableList<String>?) {
        }

        override fun onPermissionResult(granted: Boolean) {
            // If location permissions were granted and a higher level
            // android version. Request background location permissions next.
            if(granted && PermissionsManager.isAndroidElevenPlus() &&
                !PermissionsManager.areLocationPermissionsGranted(this@SplashActivity)) {
                permissionsManager.requestBackgroundLocationPermissions(this@SplashActivity)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        initialize()
    }

    private fun initialize() {

        goToMain()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        permissionsManager.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if(PermissionsManager.isAndroidElevenPlus()) {
            if(permissions.isNotEmpty() && permissions.contains(Manifest.permission.ACCESS_BACKGROUND_LOCATION)) {
                countDownLatch.countDown()
            }
        } else if (permissions.isNotEmpty() && permissions.contains(Manifest.permission.ACCESS_FINE_LOCATION)) {
            countDownLatch.countDown()
        }
    }

    private fun showLicensingAlert() {
        val alertDialog = AlertDialog.Builder(this@SplashActivity)
            .setTitle("Provide an API key")
            .setMessage("In order to use the SDK's licensing is required.\nReach out to Trimble MAPS support.")
            .setPositiveButton("Ok", DialogInterface.OnClickListener { dialog, which ->
                dialog.dismiss()
                finish()
            })
            .create()

        alertDialog.window?.setGravity(Gravity.BOTTOM)
        alertDialog.show()
    }

    private fun goToMain() {

        MainScope().launch {
            withContext(dispatcher) {


//                launch(Dispatchers.Main) {
//                    TrimbleMaps.getInstance(applicationContext)
//                }

                if ((PermissionsManager.isAndroidElevenPlus() && ContextCompat.checkSelfPermission(this@SplashActivity,
                        Manifest.permission.ACCESS_BACKGROUND_LOCATION
                    ) == 0)
                    || ContextCompat.checkSelfPermission(this@SplashActivity, Manifest.permission.ACCESS_FINE_LOCATION) == 0) {
                    countDownLatch.countDown()
                }
                else {
                    permissionsManager.listener = permissionsListener
                    permissionsManager.requestLocationPermissions(this@SplashActivity)
                }
                delay(750L)
                countDownLatch.countDown()

                countDownLatch.await()
                launch(Dispatchers.Main) {
                    startActivity(Intent(this@SplashActivity, MainActivity::class.java))
                    finish()
                }
            }
        }
    }
}