package com.crescentflare.unilayout.views;

import android.content.Context;
import android.text.Layout;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.TextView;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a view with simple text
 * Extends TextView, provides a bug fix for multi-line measurement of width
 */
public class UniTextView extends TextView
{
    // ---
    // Members
    // ---

    private boolean disableLineWidthFix = false;


    // ---
    // Initialization
    // ---

    public UniTextView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniTextView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }


    // ---
    // Custom layout
    // ---

    public void setDisableLineWidthFix(boolean disableLineWidthFix)
    {
        this.disableLineWidthFix = disableLineWidthFix;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (!disableLineWidthFix && MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.AT_MOST)
        {
            Layout layout = getLayout();
            if (layout != null)
            {
                int lines = layout.getLineCount();
                if (lines > 1)
                {
                    int fixedWidth = getCompoundPaddingLeft() + (int)Math.ceil(getMaxLineWidth(layout, lines)) + getCompoundPaddingRight();
                    if (fixedWidth < getMeasuredWidth())
                    {
                        super.onMeasure(MeasureSpec.makeMeasureSpec(fixedWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
                    }
                }
            }
        }
    }

    private float getMaxLineWidth(Layout layout, int lines)
    {
        float maxWidth = 0.0f;
        for (int i = 0; i < lines; i++)
        {
            maxWidth = Math.max(maxWidth, layout.getLineWidth(i));
        }
        return maxWidth;
    }
}
