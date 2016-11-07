package com.crescentflare.unilayoutexample.reusingcontainer.views;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.TextView;

import com.crescentflare.unilayout.containers.UniFrameContainer;
import com.crescentflare.unilayoutexample.R;

/**
 * Reusing container example: section view
 * A view type in the reusing container showing a section
 */
public class SectionView extends UniFrameContainer
{
    // ---
    // Members
    // ---

    private TextView textView;


    // ---
    // Initialization
    // ---

    public SectionView(Context context)
    {
        super(context);

        int topPadding = (int)(getResources().getDisplayMetrics().density * 4);
        int sidePadding = (int)(getResources().getDisplayMetrics().density * 8);
        LayoutInflater.from(getContext()).inflate(R.layout.view_section, this, true);
        setPadding(sidePadding, topPadding, sidePadding, 0);
        textView = (TextView)findViewById(R.id.view_section_text);
    }


    // ---
    // Set values
    // ---

    public void setText(String text)
    {
        textView.setText(text);
    }
}
