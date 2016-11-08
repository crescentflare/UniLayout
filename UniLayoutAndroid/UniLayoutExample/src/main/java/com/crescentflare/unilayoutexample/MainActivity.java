package com.crescentflare.unilayoutexample;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.crescentflare.unilayoutexample.nestedlayouts.NestedLayoutsActivity;
import com.crescentflare.unilayoutexample.reusingcontainer.ReusingContainerActivity;

/**
 * The main activity shows a small layout example, explanation and buttons to show other layout examples
 */
public class MainActivity extends AppCompatActivity
{
    // ---
    // Initialization
    // ---

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


    // ---
    // Interaction
    // ---

    private void showNestedLayouts()
    {
        Intent intent = new Intent(this, NestedLayoutsActivity.class);
        startActivity(intent);
    }

    private void showReusingContainer()
    {
        Intent intent = new Intent(this, ReusingContainerActivity.class);
        startActivity(intent);
    }
}
