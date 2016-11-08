package com.crescentflare.unilayoutexample.nestedlayouts;

import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;

import com.crescentflare.unilayoutexample.R;

/**
 * The nested layouts activity loads a layout file with nested UniLayout containers
 */
public class NestedLayoutsActivity extends AppCompatActivity
{
    // ---
    // Initialization
    // ---

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_nested_layouts);
        setTitle(getString(R.string.example_nested_layouts));

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
        {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setHomeButtonEnabled(true);
        }
    }


    // ---
    // Menu handling
    // ---

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        if (item.getItemId() == android.R.id.home)
        {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
