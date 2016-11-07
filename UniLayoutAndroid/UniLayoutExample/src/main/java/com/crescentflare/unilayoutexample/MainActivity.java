package com.crescentflare.unilayoutexample;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.List;

/**
 * The main activity shows a small layout example, explanation and buttons to show other layout examples
 */
public class MainActivity extends AppCompatActivity
{
    /**
     * Initialization
     */

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        // Set view
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Button to open nested layouts example
        findViewById(R.id.activity_main_nestedlayouts).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                showNestedLayouts();
            }
        });

        // Button to open reusing container example
        findViewById(R.id.activity_main_reusingcontainer).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                showReusingContainer();
            }
        });
    }


    /**
     * Interaction
     */

    private void showNestedLayouts()
    {
        Intent intent = new Intent(this, NestedLayoutsActivity.class);
        startActivity(intent);
    }

    private void showReusingContainer()
    {
        // TODO: implement
    }
}
