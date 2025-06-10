package com.example.myapp;

import com.example.myapp.R;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.view.ViewGroup.LayoutParams;
import android.graphics.Color;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Create a TextView
        TextView textView = new TextView(this);
        textView.setText("Hello from Manual App!");
        textView.setTextSize(30); // Set text size
        textView.setTextColor(Color.RED); // Set text color

        // Set layout parameters for the TextView
        LayoutParams params = new LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT
        );
        textView.setLayoutParams(params);

        // Set the TextView as the content view for the activity
        setContentView(textView);
    }
}