package com.crescentflare.unilayoutexample.reusingcontainer.views;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.crescentflare.unilayout.containers.UniFrameContainer;
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


    // ---
    // Initialization
    // ---

    public ItemView(Context context)
    {
        super(context);

        int verticalPadding = (int)(getResources().getDisplayMetrics().density * 4);
        int sidePadding = (int)(getResources().getDisplayMetrics().density * 8);
        LayoutInflater.from(getContext()).inflate(R.layout.view_item, this, true);
        setPadding(sidePadding, verticalPadding, sidePadding, verticalPadding);
        setBackgroundColor(Color.WHITE);
        setOrientation(HORIZONTAL);
        titleView = (TextView)findViewById(R.id.view_item_title);
        additionalView = (TextView)findViewById(R.id.view_item_additional);
        valueView = (TextView)findViewById(R.id.view_item_value);
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
