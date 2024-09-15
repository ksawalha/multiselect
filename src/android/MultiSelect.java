package com.example.multiselect;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.content.pm.PackageManager;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.database.Cursor;
import android.content.ContentResolver;
import android.util.Base64;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;

import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;
import android.app.Activity;

public class MultiSelect extends CordovaPlugin {

    private static final int PICK_FILE_REQUEST = 1;
    private static final int REQUEST_PERMISSION = 2;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("chooseFiles")) {
            this.callbackContext = callbackContext;
            if (ContextCompat.checkSelfPermission(cordova.getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(cordova.getActivity(), new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_PERMISSION);
            } else {
                openFileChooser();
            }
            return true;
        }
        return false;
    }

    private void openFileChooser() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        cordova.startActivityForResult(this, intent, PICK_FILE_REQUEST);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PICK_FILE_REQUEST && resultCode == Activity.RESULT_OK) {
            JSONArray jsonArray = new JSONArray();

            if (data.getClipData() != null) {
                // Multiple files selected
                for (int i = 0; i < data.getClipData().getItemCount(); i++) {
                    Uri uri = data.getClipData().getItemAt(i).getUri();
                    try {
                        jsonArray.put(getFileData(uri));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            } else {
                // Single file selected
                Uri uri = data.getData();
                try {
                    jsonArray.put(getFileData(uri));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            // Return the JSON structure
            callbackContext.success(jsonArray);
        } else {
            callbackContext.error("Failed to select file.");
        }
    }

    private JSONObject getFileData(Uri uri) throws JSONException {
        JSONObject fileData = new JSONObject();
        String fileName = getFileName(uri);
        String fullPath = uri.getPath(); // Adjust as needed

        fileData.put("filename", fileName);
        fileData.put("fullPath", fullPath);

        return fileData;
    }

    private String getFileName(Uri uri) {
        String fileName = null;
        if (uri.getScheme().equals("content")) {
            Cursor cursor = cordova.getActivity().getContentResolver().query(uri, null, null, null, null);
            if (cursor != null) {
                cursor.moveToFirst();
                fileName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                cursor.close();
            }
        }
        return fileName != null ? fileName : uri.getLastPathSegment();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_PERMISSION) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                openFileChooser();
            } else {
                callbackContext.error("Permission denied.");
            }
        }
    }
}
