package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.TextView;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a view with simple text
 * Extends TextView, includes a workaround to get text alignment to work with minimum width
 */
public class UniTextView extends TextView
{
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
    // Override measure to work with minimum width and alignment
    // ---

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams instanceof UniLayoutParams)
        {
            UniLayoutParams uniLayoutParams = (UniLayoutParams)layoutParams;
            int specMode = MeasureSpec.getMode(widthMeasureSpec);
            if (specMode != MeasureSpec.EXACTLY && getMeasuredWidth() < uniLayoutParams.minWidth)
            {
                int limitWidth = uniLayoutParams.minWidth;
                if (specMode == MeasureSpec.AT_MOST)
                {
                    limitWidth = Math.min(limitWidth, MeasureSpec.getSize(widthMeasureSpec));
                }
                super.onMeasure(MeasureSpec.makeMeasureSpec(limitWidth, MeasureSpec.EXACTLY), heightMeasureSpec);
            }
        }
    }
}
