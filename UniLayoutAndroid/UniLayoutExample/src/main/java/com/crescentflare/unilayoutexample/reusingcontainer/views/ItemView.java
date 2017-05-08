package com.crescentflare.unilayoutexample.reusingcontainer.views;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.crescentflare.unilayout.containers.UniLinearContainer;
import com.crescentflare.unilayoutexample.R;

/**
 * Reusing container example: section view
 * A view type in the reusing container showing a section
 */
public class ItemView extends UniLinearContainer
{
    // ---
    // Members
    // ---

    private TextView titleView;
    private TextView additionalView;
    private TextView valueView;
    private View divider;


    // ---
    // Initialization
    // ---

    public ItemView(Context context)
    {
        super(context);

        LayoutInflater.from(getContext()).inflate(R.layout.view_item, this, true);
        setBackgroundColor(Color.WHITE);
        setOrientation(VERTICAL);
        titleView = (TextView)findViewById(R.id.view_item_title);
        additionalView = (TextView)findViewById(R.id.view_item_additional);
        valueView = (TextView)findViewById(R.id.view_item_value);
    }

    @Override
    public void setLayoutParams(LayoutParams params)
    {
        params.width = LayoutParams.MATCH_PARENT;
        super.setLayoutParams(params);
    }


    // ---
    // Set values
    // ---

    public void setTitle(String text)
    {
        titleView.setText(text);
        titleView.setVisibility(text.length() > 0 ? VISIBLE : GONE);
    }

    public void setAdditional(String text)
    {
        additionalView.setText(text);
        additionalView.setVisibility(text.length() > 0 ? VISIBLE : GONE);
    }

    public void setValue(String text)
    {
        valueView.setText(text);
        valueView.setVisibility(text.length() > 0 ? VISIBLE : GONE);
    }
}
