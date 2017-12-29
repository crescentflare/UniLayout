package com.crescentflare.unilayoutexample.reusingcontainer.views;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.TextView;

import com.crescentflare.unilayout.containers.UniLinearContainer;
import com.crescentflare.unilayoutexample.R;

/**
 * Reusing container example: under item view
 * A view type in the reusing container showing a piece of hidden text which can be shown by
 * swiping an item to the side
 */
public class UnderItemView extends UniLinearContainer
{
    // ---
    // Members
    // ---

    private TextView titleView;
    private TextView additionalView;


    // ---
    // Initialization
    // ---

    public UnderItemView(Context context)
    {
        super(context);

        LayoutInflater.from(getContext()).inflate(R.layout.view_under_item, this, true);
        setOrientation(VERTICAL);
        titleView = (TextView)findViewById(R.id.view_under_item_title);
        additionalView = (TextView)findViewById(R.id.view_under_item_additional);
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
}
