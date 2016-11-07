package com.crescentflare.unilayoutexample.reusingcontainer;

import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;

import com.crescentflare.unilayoutexample.R;

/**
 * The reusing container activity shows a list of items within a recycler view
 */
public class ReusingContainerActivity extends AppCompatActivity
{
    /**
     * Members
     */

    private ReusingContainerAdapter adapter = new ReusingContainerAdapter();


    /**
     * Initialization
     */

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reusing_container);
        setTitle(getString(R.string.example_reusing_container));

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null)
        {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setHomeButtonEnabled(true);
        }

        ReusingContainerView reusingView = (ReusingContainerView)findViewById(R.id.activity_reusing_container_view);
        reusingView.setAdapter(adapter);

        adapter.addItem(new ReusableItem(ReusableItem.Type.Section, "Supported containers"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.TopDivider));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Horizontal scroll container", "Contains a single content view which can scroll horizontally, use linear container as a content view for scrollable layouts", "Scroll"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Vertical scroll container", "Contains a single content view which can scroll vertically, use linear container as a content view for scrollable layouts", "Scroll"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Linear container", "Aligns items horizontally or vertically, depending on its orientation", "Layout"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Frame container", "A simple container to contain one view, or add multiple overlapping views", "Layout"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.BottomDivider));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Section, "Supported views"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.TopDivider));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Button view", "Extends Button, currently only used to match the naming convention with iOS", "Button"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Image view", "Extends ImageView, currently only used to match the naming convention with iOS", "Image"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "Text view", "Extends TextView, currently only used to match the naming convention with iOS", "Text"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.Item, "View", "Extends View to support padding for size calculation", "Container"));
        adapter.addItem(new ReusableItem(ReusableItem.Type.BottomDivider));
    }


    /**
     * Menu handling
     */

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
